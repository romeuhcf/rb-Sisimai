module Sisimai
  module MTA
    # Sisimai::MTA::ApacheJames parses a bounce email which created by ApacheJames.
    # Methods in the module are called from only Sisimai::Message.
    module ApacheJames
      # Imported from p5-Sisimail/lib/Sisimai/MTA/ApacheJames.pm
      class << self
        require 'sisimai/mta'
        require 'sisimai/rfc5322'

        Re0 = {
          :'subject'    => %r/\A\[BOUNCE\]\z/,
          :'received'   => %r/JAMES SMTP Server/,
          :'message-id' => %r/\d+[.]JavaMail[.].+[@]/,
        }
        Re1 = {
          # apache-james-2.3.2/src/java/org/apache/james/transport/mailets/
          #   AbstractNotify.java|124:  out.println("Error message below:");
          #   AbstractNotify.java|128:  out.println("Message details:");
          :begin  => %r/\AContent-Disposition:[ ]inline/,
          :error  => %r/\AError message below:\z/,
          :rfc822 => %r|\AContent-Type: message/rfc822|,
          :endof  => %r/\A__END_OF_EMAIL_MESSAGE__\z/,
        }
        Indicators = Sisimai::MTA.INDICATORS
        LongFields = Sisimai::RFC5322.LONGFIELDS
        RFC822Head = Sisimai::RFC5322.HEADERFIELDS

        def description; return 'Java Apache Mail Enterprise Server'; end
        def smtpagent;   return 'ApacheJames'; end
        def headerlist;  return []; end
        def pattern;     return Re0; end

        # Parse bounce messages from Apache James
        # @param         [Hash] mhead       Message header of a bounce email
        # @options mhead [String] from      From header
        # @options mhead [String] date      Date header
        # @options mhead [String] subject   Subject header
        # @options mhead [Array]  received  Received headers
        # @options mhead [String] others    Other required headers
        # @param         [String] mbody     Message body of a bounce email
        # @return        [Hash, Nil]        Bounce data list and message/rfc822
        #                                   part or nil if it failed to parse or
        #                                   the arguments are missing
        def scan(mhead, mbody)
          return nil unless mhead
          return nil unless mbody

          match  = 0
          match += 1 if mhead['subject'] =~ Re0[:subject]
          match += 1 if mhead['message-id'] && mhead['message-id'] =~ Re0[:'message-id']
          match += 1 if mhead['received'].find { |a| a =~ Re0[:received] }
          return if match == 0

          dscontents = []; dscontents << Sisimai::MTA.DELIVERYSTATUS
          hasdivided = mbody.split("\n")
          rfc822next = { 'from' => false, 'to' => false, 'subject' => false }
          rfc822part = ''     # (String) message/rfc822-headers part
          previousfn = ''     # (String) Previous field name
          readcursor = 0      # (Integer) Points the current cursor position
          recipients = 0      # (Integer) The number of 'Final-Recipient' header
          diagnostic = ''     # (String) Alternative diagnostic message
          subjecttxt = nil    # (String) Alternative Subject text
          gotmessage = -1     # (Integer) Flag for error message
          v = nil

          hasdivided.each do |e|

            if readcursor == 0
              # Beginning of the bounce message or delivery status part
              if e =~ Re1[:begin]
                readcursor |= Indicators[:'deliverystatus']
                next
              end
            end

            if readcursor & Indicators[:'message-rfc822'] == 0
              # Beginning of the original message part
              if e =~ Re1[:rfc822]
                readcursor |= Indicators[:'message-rfc822']
                next
              end
            end

            if readcursor & Indicators[:'message-rfc822'] > 0
              # After "message/rfc822"
              if cv = e.match(/\A([-0-9A-Za-z]+?)[:][ ]*.+\z/)
                # Get required headers only
                lhs = cv[1].downcase
                previousfn = '';
                next unless RFC822Head.key?(lhs)

                previousfn  = lhs
                rfc822part += e + "\n"

              elsif e =~ /\A[ \t]+/
                # Continued line from the previous line
                next if rfc822next[previousfn]
                rfc822part += e + "\n" if LongFields.key?(previousfn)

              else
                # Check the end of headers in rfc822 part
                next unless LongFields.key?(previousfn)
                next unless e.empty?
                rfc822next[previousfn] = true
              end

            else
              # Before "message/rfc822"
              next if readcursor & Indicators[:'deliverystatus'] == 0
              next if e.empty?

              # Message details:
              #   Subject: Nyaaan
              #   Sent date: Thu Apr 29 01:20:50 JST 2015
              #   MAIL FROM: shironeko@example.jp
              #   RCPT TO: kijitora@example.org
              #   From: Neko <shironeko@example.jp>
              #   To: kijitora@example.org
              #   Size (in bytes): 1024
              #   Number of lines: 64
              v = dscontents[-1]

              if cv = e.match(/\A[ ][ ]RCPT[ ]TO:[ ]([^ ]+[@][^ ]+)\z/)
                #   RCPT TO: kijitora@example.org
                if v['recipient']
                  # There are multiple recipient addresses in the message body.
                  dscontents << Sisimai::MTA.DELIVERYSTATUS
                  v = dscontents[-1]
                end
                v['recipient'] = cv[1]
                recipients += 1

              elsif cv = e.match(/\A[ ][ ]Sent[ ]date:[ ](.+)\z/)
                #   Sent date: Thu Apr 29 01:20:50 JST 2015
                v['date'] = cv[1]

              elsif cv = e.match(/\A[ ][ ]Subject:[ ](.+)\z/)
                #   Subject: Nyaaan
                subjecttxt = cv[1]

              else
                next if gotmessage == 1
                if v['diagnosis']
                  # Get an error message text
                  if e =~ /\AMessage[ ]details:\z/
                    # Message details:
                    #   Subject: nyaan
                    #   ...
                    gotmessage = 1
                  else
                    # Append error message text like the followng:
                    #   Error message below:
                    #   550 - Requested action not taken: no such user here
                    v['diagnosis'] ||= ''
                    v['diagnosis']  += ' ' + e
                  end

                else
                  # Error message below:
                  # 550 - Requested action not taken: no such user here
                  v['diagnosis'] = e if e =~ Re1[:error]
                end
              end
            end
          end

          return nil if recipients == 0
          require 'sisimai/string'
          require 'sisimai/smtp/status'

          dscontents.map do |e|
            e['agent'] = Sisimai::MTA::ApacheJames.smtpagent

            if mhead['received'].size > 0
              # Get localhost and remote host name from Received header.
              r0 = mhead['received']
              ['lhost', 'rhost'].each { |a| e[a] ||= '' }
              e['lhost'] = Sisimai::RFC5322.received(r0[0]).shift if e['lhost'].empty?
              e['rhost'] = Sisimai::RFC5322.received(r0[-1]).pop  if e['rhost'].empty?
            end
            e['diagnosis'] = Sisimai::String.sweep(e['diagnosis'] || diagnostic)
            e['status']    = Sisimai::SMTP::Status.find(e['diagnosis'])
            e.each_key { |a| e[a] ||= '' }
          end

          return { 'ds' => dscontents, 'rfc822' => rfc822part }
        end

      end
    end
  end
end


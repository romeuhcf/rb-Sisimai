module Sisimai
  module Reason
    # Sisimai::Reason::SpamDetected checks the bounce reason is "spamdetected"
    # due to Spam content in the message or not. This class is called only
    # Sisimai::Reason class.
    #
    # This is the error that the message you sent was rejected by "spam filter"
    # which is running on the remote host.
    # This reason has added in Sisimai 4.1.25 and does not exist in any version
    # of bounceHammer.
    #
    #    Action: failed
    #    Status: 5.7.1
    #    Diagnostic-Code: smtp; 550 5.7.1 Message content rejected, UBE, id=00000-00-000
    #    Last-Attempt-Date: Thu, 9 Apr 2008 23:34:45 +0900 (JST)
    module SpamDetected
      # Imported from p5-Sisimail/lib/Sisimai/Reason/SpamDetected.pm
      class << self
        def text; return 'spamdetected'; end
        def description; return 'Email rejected by spam filter running on the remote host'; end

        # Try to match that the given text and regular expressions
        # @param    [String] argv1  String to be matched with regular expressions
        # @return   [True,False]    false: Did not match
        #                           true: Matched
        def match(argv1)
          return nil unless argv1
          regex = %r{(?>
             ["]The[ ]mail[ ]server[ ]detected[ ]your[ ]message[ ]as[ ]spam[ ]and[ ]
                has[ ]prevented[ ]delivery[.]["]    # CPanel/Exim with SA rejections on
            |(?:\d[.]\d[.]\d|\d{3})[ ]spam\z
            |appears[ ]to[ ]be[ ]unsolicited
            |Blacklisted[ ]URL[ ]in[ ]message
            |block[ ]for[ ]spam
            |blocked[ ]by[ ](?:
               policy:[ ]no[ ]spam[ ]please
              |spamAssassin                   # rejected by SpamAssassin
              )
            |blocked[ ]for[ ]abuse[.][ ]see[ ]http://att[.]net/blocks   # AT&T
            |bulk[ ]email
            |content[ ]filter[ ]rejection
            |cyberoam[ ]anti[ ]spam[ ]engine[ ]has[ ]identified[ ]this[ ]email[ ]as[ ]a[ ]bulk[ ]email
            |denied[ ]due[ ]to[ ]spam[ ]list
            |dt:spm[ ]mx.+[ ]http://mail[.]163[.]com/help/help_spam_16[.]htm
            |greylisted.?.[ ]please[ ]try[ ]again[ ]in
            |http://(?:www[.]spamhaus[.]org|dsbl[.]org)
            |listed[ ]in[ ]work[.]drbl[.]imedia[.]ru
            |mail[ ](?:
               appears[ ]to[ ]be[ ]unsolicited    # rejected due to spam
              |content[ ]denied   # http://service.mail.qq.com/cgi-bin/help?subtype=1&&id=20022&&no=1000726
              |rejete.+[A-Z]{3}.+506
              )
            |may[ ]consider[ ]spam
            |message[ ](?:
               considered[ ]as[ ]spam[ ]or[ ]virus
              |content[ ]rejected
              |filtered
              |filtered[.][ ](?:
                 please[ ]see[ ]the[ ]faqs[ ]section[ ]on[ ]spam
                |Refer[ ]to[ ]the[ ]Troubleshooting[ ]page[ ]at[ ]
                )
              |looks[ ]like[ ]spam
              |not[ ]accepted[ ]for[ ]policy[ ]reasons[.][ ]See[ ]http:   # Yahoo!
              |refused[ ]by[ ]mailmarshal[ ]spamprofiler
              |rejected[ ](?:
                 as[ ]spam
                |because[ ]of[ ]unacceptable[ ]content
                |due[ ]to[ ]suspected[ ]spam[ ]content
                |for[ ]policy[ ]reasons
                )
              )
            |our[ ](?:
               email[ ]server[ ]thinks[ ]this[ ]email[ ]is[ ]spam
              |filters[ ]rate[ ]at[ ]and[ ]above[ ].+[ ]percent[ ]probability[ ]of[ ]being[ ]spam
              |system[ ]has[ ]detected[ ]that[ ]this[ ]message[ ]is
              )
            |probable[ ]spam
            |REJECT[ ]bulk[.]advertising
            |Reject,.+[ ][-][ ]SPAM[.][ ]
            |rejected(?:
               :[ ]spamassassin[ ]score[ ]
              |[ ]by[ ].+[ ][(]spam[)]
              |[ ]due[ ]to[ ]spam[ ]content
              )
            |rejecting[ ]banned[ ]content
            |related[ ]to[ ]content[ ]with[ ]spam[-]like[ ]characteristics
            |rule[ ]imposed[ ]as[ ].+is[ ]blacklisted[ ]on              # Mailmarshal RBLs
            |Sender[ ]domain[ ]listed[ ]at[ ].+
            |sending[ ]address[ ]not[ ]accepted[ ]due[ ]to[ ]spam[ ]filter
            |spam[ ](?:
               .+[ ]exceeded
              |blocked
              |check
              |content[ ]matched
              |detected
              |email
              |email[ ]not[ ]accepted
              |message[ ]rejected[.]       # mail.ru
              |not[ ]accepted
              |refused
              |rejection
              |Reporting[ ]Address    # SendGrid: a message to an address has previously been marked as Spam by the recipient.
              |score[ ]
              )
            |spambouncer[ ]identified[ ]spam    # SpamBouncer identified SPAM
            |spamming[ ]not[ ]allowed
            |Too[ ]much[ ]spam[.]               # Earthlink
            |the[ ]message[ ](?:
               has[ ]been[ ]rejected[ ]by[ ]spam[ ]filtering[ ]engine
              |was[ ]rejected[ ]due[ ]to[ ]classification[ ]as[ ]bulk[ ]mail
              )
            |The[ ]content[ ]of[ ]this[ ]message[ ]looked[ ]like[ ]spam # SendGrid
            |This[ ](?:e-mail|mail)[ ](?:
               cannot[ ]be[ ]forwarded[ ]because[ ]it[ ]was[ ]detected[ ]as[ ]spam
              |is[ ]classified[ ]as[ ]spam[ ]and[ ]is[ ]rejected
              )
            |this[ ]message[ ](?:
               appears[ ]to[ ]be[ ]spam
              |has[ ]been[ ](?:
                 identified[ ]as[ ]spam
                |scored[ ]as[ ]spam[ ]with[ ]a[ ]probability
                )
              |scored[ ].+[ ]spam[ ]points
              |was[ ]classified[ ]as[ ]spam
              |was[ ]rejected[ ]by[ ]Recurrent[ ]Pattern[ ]Detection[ ]System
              )
            |transaction[ ]failed[ ]spam[ ]message[ ]not[ ]queued       # SendGrid
            |we[ ]dont[ ]accept[ ]spam
            |you're[ ]using[ ]a[ ]mass[ ]mailer
            |your[ ](?:
               email[ ](?:
                 appears[ ]similar[ ]to[ ]spam[ ]we[ ]have[ ]received[ ]before
                |breaches[ ]local[ ]URIBL[ ]policy
                |had[ ]spam[-]like[ ]
                |is[ ](?:considered|probably)[ ]spam
                |was[ ]detected[ ]as[ ]spam
                )
              |message[ ](?:
                 as[ ]spam[ ]and[ ]has[ ]prevented[ ]delivery
                |has[ ]been[ ](?:
                   temporarily[ ]blocked[ ]by[ ]our[ ]filter
                  |rejected[ ]because[ ]it[ ]appears[ ]to[ ]be[ ]SPAM
                  )
                |has[ ]triggered[ ]a[ ]SPAM[ ]block
                |may[ ]contain[ ]the[ ]spam[ ]contents
                |failed[ ]several[ ]antispam[ ]checks
                )
              )
            )
          }ix

          return true if argv1 =~ regex
          return false
        end

        # Rejected due to spam content in the message
        # @param    [Sisimai::Data] argvs   Object to be detected the reason
        # @return   [True,False]            true: rejected due to spam
        #                                   false: is not rejected due to spam
        # @see http://www.ietf.org/rfc/rfc2822.txt
        def true(argvs)
          return nil unless argvs
          return nil unless argvs.is_a? Sisimai::Data
          return nil unless argvs.deliverystatus.size > 0
          return true if argvs.reason == 'spamdetected'

          require 'sisimai/smtp/status'
          return true if Sisimai::SMTP::Status.name(argvs.deliverystatus) == 'spamdetected'
          return true if match(argvs.diagnosticcode)
          return false
        end

      end
    end
  end
end




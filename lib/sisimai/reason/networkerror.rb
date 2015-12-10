module Sisimai
  module Reason
    # Sisimai::Reason::NetworkError checks the bounce reason is "networkerror"
    # or not. This class is called only Sisimai::Reason class.
    #
    # This is the error that SMTP connection failed due to DNS look up failure
    # or other network problems. This reason has added in Sisimai 4.1.12 and does
    # not exist in any version of bounceHammer.
    #   A message is delayed for more than 10 minutes for the following
    #   list of recipients:
    #
    #   kijitora@neko.example.jp: Network error on destination MXs
    module NetworkError
      # Imported from p5-Sisimail/lib/Sisimai/Reason/NetworkError.pm
      class << self
        def text; return 'networkerror'; end

        # Try to match that the given text and regular expressions
        # @param    [String] argv1  String to be matched with regular expressions
        # @return   [True,False]    false: Did not match
        #                           true: Matched
        def match(argv1)
          return nil unless argv1
          regex = %r{(?:
             DNS[ ]records[ ]for[ ]the[ ]destination[ ]computer[ ]could[ ]not[ ]be[ ]found
            |Hop[ ]count[ ]exceeded[ ]-[ ]possible[ ]mail[ ]loop
            |host[ ]is[ ]unreachable
            |mail[ ]forwarding[ ]loop[ ]for[ ]
            |malformed[ ]name[ ]server[ ]reply
            |maximum[ ]forwarding[ ]loop[ ]count[ ]exceeded
            |message[ ]looping
            |name[ ]service[ ]error
            |too[ ]many[ ]hops
            |unrouteable[ ]mail[ ]domain
            )
          }ix

          return true if argv1 =~ regex
          return false
        end

        def true; return nil; end

      end
    end
  end
end




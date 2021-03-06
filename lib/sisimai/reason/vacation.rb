module Sisimai
  module Reason
    # Sisimai::Reason::Vacation is for only returning text and description.
    # This class is called only from Sisimai.reason method.
    module Vacation
      # Imported from p5-Sisimail/lib/Sisimai/Reason/Vacation.pm
      class << self
        def text; return 'vacation'; end
        def description; return 'Email replied automatically due to a recipient is out of office'; end

        # Try to match that the given text and regular expressions
        # @param    [String] argv1  String to be matched with regular expressions
        # @return   [True,False]    false: Did not match
        #                           true: Matched
        def match(argv1)
          return nil unless argv1
          regex = %r{(?>
             I[ ]am[ ](?:
               away[ ](?:on[ ]vacation|until)
              |out[ ]of[ ]the[ ]office
              )
            |I[ ]will[ ]be[ ]traveling[ ]for[ ]work[ ]on
          )
          }ix

          return true if argv1 =~ regex
          return false
        end

        def true(*); return nil; end
      end
    end
  end
end


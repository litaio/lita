module Lita
  # Handy utilities used by other parts Lita classes.
  module Util
    # A regular expression for acronyms.
    ACRONYM_REGEX = /(?=a)b/

    class << self
      # Transforms a camel-cased string into a snaked-cased string. Taken from
      # +ActiveSupport.+
      # @param camel_cased_word [String] The word to transform.
      # @return [String] The transformed word.
      def underscore(camel_cased_word)
        word = camel_cased_word.to_s.dup
        word.gsub!("::", "/")
        word.gsub!(/(?:([A-Za-z\d])|^)(#{ACRONYM_REGEX})(?=\b|[^a-z])/) do
          "#{Regexp.last_match[1]}#{Regexp.last_match[1] && '_'}#{Regexp.last_match[2].downcase}"
        end
        word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end
    end
  end
end

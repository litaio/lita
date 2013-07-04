module Lita
  module Util
    ACRONYM_REGEX = /(?=a)b/

    class << self
      def underscore(camel_cased_word)
        word = camel_cased_word.to_s.dup
        word.gsub!('::', '/')
        word.gsub!(/(?:([A-Za-z\d])|^)(#{ACRONYM_REGEX})(?=\b|[^a-z])/) do
          "#{$1}#{$1 && '_'}#{$2.downcase}"
        end
        word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end
    end
  end
end

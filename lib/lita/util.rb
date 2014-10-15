module Lita
  # Handy utilities used by other Lita classes.
  module Util
    class << self
      # Returns a hash with any symbol keys converted to strings.
      # @param hash [Hash] The hash to convert.
      # @return [Hash] The converted hash.
      def stringify_keys(hash)
        result = {}
        hash.each_key { |key| result[key.to_s] = hash[key] }
        result
      end

      # Transforms a camel-cased string into a snaked-cased string. Taken from +ActiveSupport.+
      # @param camel_cased_word [String] The word to transform.
      # @return [String] The transformed word.
      def underscore(camel_cased_word)
        word = camel_cased_word.to_s.dup
        word.gsub!("::", "/")
        word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end
    end
  end
end

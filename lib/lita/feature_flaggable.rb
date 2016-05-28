require "set"

require "i18n"

require_relative "errors"
require_relative "feature_flag"

module Lita
  # Allows an object to opt-in to new features that are breaking changes before they become the
  # default in the next version of Lita.
  # @since 5.0.0
  module FeatureFlaggable
    # A set of features this object has opted-in to.
    # @api private
    attr_reader :enabled_features

    # Initializes the enabled features set.
    def self.extended(klass)
      klass.instance_eval { @enabled_features = Set.new }
    end

    # Initializes the enabled features set for any inheriting classes.
    def inherited(klass)
      super
      klass.instance_eval { @enabled_features = Set.new }
    end

    # Enable a feature for this object.
    # @param name [Symbol] The name of the feature.
    # @return [void]
    # @raise [UnknownFeatureError] If the feature is not known.
    def feature(name)
      if FEATURE_FLAGS.key?(name)
        @enabled_features.add(name)
      else
        raise UnknownFeatureError, I18n.t("lita.feature_flag.unknown_flag", name: name)
      end
    end

    # Check if this object has enabled the given feature.
    # @param name [Symbol] The name of the feature.
    # @api private
    def feature_enabled?(name)
      enabled_features.include?(name)
    end
  end
end

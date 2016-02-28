require "set"

require "i18n"

require_relative "errors"
require_relative "feature_flag"

module Lita
  module FeatureFlaggable
    attr_reader :enabled_features

    def self.extended(base)
      base.instance_eval { @enabled_features = Set.new }
    end

    def feature(name)
      if features.key?(name)
        @enabled_features.add(name)
      else
        raise UnknownFeatureError, I18n.t("lita.feature_flag.unknown_flag", name: name)
      end
    end

    def feature_enabled?(name)
      enabled_features.include?(name)
    end

    def features
      FEATURE_FLAGS
    end
  end
end

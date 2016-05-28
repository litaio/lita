require "i18n"

module Lita
  # A flag representing a breaking change between versions of Lita. Users will receive a warning
  # message unless they opt-in to a feature before its behavior becomes the default.
  # @api private
  # @since 5.0.0
  class FeatureFlag
    # The user-facing description of the behavior that will change.
    attr_reader :description
    # The name of the feature that users must opt-in to.
    attr_reader :name
    # The version of Lita in which the new behavior will be enabled by default.
    attr_reader :version_threshold

    def initialize(name, description, version_threshold)
      self.description = description
      self.name = name.to_sym
      self.version_threshold = version_threshold
    end

    # Return a warning message that behavior will be changing.
    def change_warning
      I18n.t(
        "lita.feature_flag.change_warning",
        description: description,
        version: version_threshold,
      )
    end

    # Return a warning message that the feature is now on by default and that the flag will
    # be removed in the next major version of Lita.
    def flag_removal_warning_for(object)
      I18n.t(
        "lita.feature_flag.flag_removal_warning",
        name: name,
        object_name: object_name(object),
        version_default: version_threshold,
        version_removed: next_version(version_threshold)
      )
    end

    # Return a warning message that behavior will be changing and that the user should opt-in
    # to the new behavior by enabling the feature.
    def opt_in_warning_for(object)
      [
        change_warning,
        I18n.t(
          "lita.feature_flag.opt_in_warning",
          name: name,
          object_name: object_name(object),
        ),
      ].join("\n\n")
    end

    private

    # Returns the major version number after the given one.
    def next_version(version)
      major_version, *_unused = version.split(/\./)

      "#{major_version.to_i + 1}.0.0"
    end

    # Gets the name of the object being checked for feature flags for use in warning messages.
    def object_name(object)
      if object.respond_to?(:name)
        object.name
      else
        object.class.name
      end
    end

    attr_writer :description
    attr_writer :name
    attr_writer :version_threshold
  end

  # The feature flags currently available.
  FEATURE_FLAGS = {
    async_dispatch: FeatureFlag.new(
      :async_dispatch,
      I18n.t("lita.feature_flag.async_dispatch"),
      "6.0.0",
    ),
    error_handler_metadata: FeatureFlag.new(
      :error_handler_metadata,
      I18n.t("lita.feature_flag.error_handler_metadata"),
      "6.0.0",
    )
  }.freeze
end

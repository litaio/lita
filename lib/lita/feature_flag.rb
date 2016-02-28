module Lita
  class FeatureFlag
    attr_reader :description
    attr_reader :name
    attr_reader :version_threshold

    def initialize(name, description, version_threshold)
      self.description = description
      self.name = name.to_sym
      self.version_threshold = version_threshold
    end

    def flag_removal_warning_for(object)
      I18n.t(
        "lita.feature_flag.flag_removal_warning",
        name: name,
        object_name: object_name(object),
        version_default: version_threshold,
        version_removed: next_version(version_threshold)
      )
    end

    def opt_in_warning_for(object)
      I18n.t(
        "lita.feature_flag.opt_in_warning",
        description: description,
        name: name,
        object_name: object_name(object),
        version: version_threshold,
      )
    end

    private

    def next_version(version)
      major_version, *_unused = version.split(/\./)

      "#{major_version.to_i + 1}.0.0"
    end

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
end

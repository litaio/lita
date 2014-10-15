module Lita
  # A mixin for setting and getting a plugin's namespace.
  # @since 4.0.0
  module Namespace
    # Gets (and optionally sets) the namespace for a plugin. The namespace is generated from the
    # class's name by default.
    # @param value [String] If provided, sets the namespace of the plugin to the value.
    # @return [String] The namespace.
    # @raise [RuntimeError] If the plugin is an anonymous class, does not define +self.name+, and
    #   has not set a namespace manually.
    def namespace(value = nil)
      @namespace = value.to_s if value

      string_name = defined?(@namespace) ? @namespace : name

      if string_name
        Util.underscore(string_name.split("::").last)
      else
        raise I18n.t("lita.plugin.name_required")
      end
    end
  end
end

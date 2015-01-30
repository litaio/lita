module Lita
  # Finds the file path of the most appropriate template for the given adapter.
  # @api private
  # @since 4.2.0
  class TemplateResolver
    # @param template_root [String] The directory to search for templates.
    # @param template_name [String] The name of the template to search for.
    # @param adapter_name [String, Symbol] The name of the current adapter.
    def initialize(template_root, template_name, adapter_name)
      @template_root = template_root
      @template_name = template_name
      @adapter_name = adapter_name
    end

    # Returns the adapter-specific template, falling back to a generic template.
    # @return [String] The path of the template to use.
    # @raises [MissingTemplateError] If no templates with the given name exist.
    def resolve
      return adapter_template if File.exist?(adapter_template)
      return generic_template if File.exist?(generic_template)
      raise MissingTemplateError, I18n.t("lita.template.missing_template", path: generic_template)
    end

    private

    # The directory to search for templates.
    attr_reader :template_root

    # The name of the template to search for.
    attr_reader :template_name

    # The name of the current adapter.
    attr_reader :adapter_name

    # Path to the adapter-specific template.
    def adapter_template
      @adapter_template ||= File.join(template_root, "#{template_name}.#{adapter_name}.erb")
    end

    # Path to the generic template.
    def generic_template
      @generic_template ||= File.join(template_root, "#{template_name}.erb")
    end
  end
end

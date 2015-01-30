module Lita
  # A simple wrapper around ERB to render text from files or strings.
  # @since 4.2.0
  class Template
    # A clean room object to use as the binding for ERB rendering.
    # @api private
    class TemplateEvaluationContext
      # Returns the evaluation context's binding.
      # @return [Binding] The binding.
      def __get_binding
        binding
      end
    end

    class << self
      # Initializes a new Template with the contents of the file at the given path.
      # @param path [String] The path to the file to use as the template content.
      # @return Template
      def from_file(path)
        new(File.read(path).chomp)
      end
    end

    # @param source [String] A string to use as the template's content.
    def initialize(source)
      @erb = ERB.new(source, $SAFE, "<>")
    end

    # Render the template with the provided variables.
    # @param variables [Hash] A collection of variables for interpolation. Each key-value pair will
    #   make the value available inside the template as an instance variable with the key as its
    #   name.
    def render(variables = {})
      erb.result(context_binding(variables))
    end

    private

    # Create an empty object to use as the ERB context and set any provided variables in it.
    def context_binding(variables)
      context = TemplateEvaluationContext.new

      variables.each do |k, v|
        context.instance_variable_set("@#{k}", v)
      end

      context.__get_binding
    end

    # The underlying ERB object.
    attr_reader :erb
  end
end

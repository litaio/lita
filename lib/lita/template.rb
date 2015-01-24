module Lita
  class Template
    # @api private
    class TemplateEvaluationContext; end

    class << self
      def from_file(path)
        new(File.read(path).chomp)
      end
    end

    def initialize(source)
      @erb = ERB.new(source, $SAFE, "<>")
    end

    def render(variables = {})
      erb.result(context_binding(variables))
    end

    private

    def context_binding(variables)
      context = TemplateEvaluationContext.new

      variables.each do |k, v|
        context.instance_variable_set("@#{k}", v)
      end

      context.__binding__
    end

    attr_reader :erb
  end
end

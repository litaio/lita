module Lita
  class Template
    # @api private
    class TemplateEvaluationContext; end

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

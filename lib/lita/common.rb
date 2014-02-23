require "i18n"

module Lita
  class << self
    # The absolute path to Lita's templates directory.
    # @return [String] The path.
    def template_root
      File.expand_path("../../../templates", __FILE__)
    end
  end
end

I18n.load_path += Dir[File.join(Lita.template_root, "locales", "*.yml")]
I18n.enforce_available_locales = true

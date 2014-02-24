require "i18n"
require "i18n/backend/fallbacks"

module Lita
  class << self
    # Adds one or more paths to the I18n load path and reloads I18n.
    # @param paths [String, Array<String>] The path(s) to add.
    # @return [void]
    def load_locales(paths)
      I18n.load_path.concat(Array(paths))
      I18n.reload!
    end

    # The absolute path to Lita's templates directory.
    # @return [String] The path.
    def template_root
      File.expand_path("../../../templates", __FILE__)
    end
  end
end

I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
Lita.load_locales(Dir[File.join(Lita.template_root, "locales", "*.yml")])
I18n.enforce_available_locales = true

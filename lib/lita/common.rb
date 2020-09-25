require "i18n"
require "i18n/backend/fallbacks"

module Lita
  class << self
    # Adds one or more paths to the I18n load path and reloads I18n.
    # @param paths [String, Array<String>] The path(s) to add.
    # @return [void]
    # @since 3.0.0
    def load_locales(paths)
      I18n.load_path.concat(Array(paths))
      I18n.reload!
    end

    # Sets +I18n.locale+, normalizing the provided locale name.
    #
    # Note that setting this only affects the current thread. Since handler
    # methods are dispatched in new threads, changing the locale globally will
    # require calling this method at the start of every handler method.
    # Alternatively, use {Lita#default_locale=} which will affect all threads.
    # @param new_locale [Symbol, String] The code of the locale to use.
    # @return [void]
    # @since 3.0.0
    def locale=(new_locale)
      I18n.locale = new_locale.to_s.tr("_", "-")
    end

    # Sets +I18n.default_locale+, normalizing the provided locale name.
    #
    # This is preferred over {Lita#locale=} as it affects all threads.
    # @param new_locale [Symbol, String] The code of the locale to use.
    # @return [void]
    # @since 4.8.0
    def default_locale=(new_locale)
      I18n.default_locale = new_locale.to_s.tr("_", "-")
    end

    # The absolute path to Lita's templates directory.
    # @return [String] The path.
    # @since 3.0.0
    def template_root
      File.expand_path("../../../templates", __FILE__)
    end
  end
end

I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
Lita.load_locales(Dir[File.join(Lita.template_root, "locales", "*.yml")])
I18n.enforce_available_locales = false
Lita.locale = ENV["LANG"] unless ENV["LANG"].nil?
Lita.default_locale = ENV["LANG"] unless ENV["LANG"].nil?

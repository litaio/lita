module Lita
  module Namespace
    def namespace(value = nil)
      @namespace = value if value

      string_name = defined?(@namespace) ? @namespace : name

      if string_name
        Util.underscore(string_name.split("::").last)
      else
        raise I18n.t("lita.plugin.name_required")
      end
    end
  end
end

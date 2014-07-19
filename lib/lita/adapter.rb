module Lita
  # Adapters are the glue between Lita's API and a chat service.
  class Adapter
    # The instance of {Lita::Robot}.
    # @return [Lita::Robot]
    attr_reader :robot

    class << self
      # A list of configuration keys that are required for the adapter to boot.
      # @return [Array]
      attr_reader :required_configs

      # The namespace for the adapter, used for registry and for I18n. If the handler is an
      # anonymous class, it must explicitly define +self.name+.
      # @return [String] The adapter's namespace.
      # @raise [RuntimeError] If +self.name+ is not defined.
      def namespace(value = nil)
        @namespace = value if value

        string_name = defined?(@namespace) ? @namespace : name

        if string_name
          Util.underscore(string_name.split("::").last)
        else
          raise I18n.t("lita.adapter.name_required")
        end
      end

      # Defines configuration keys that are requried for the adapter to boot.
      # @param keys [String, Symbol] The required keys.
      # @return [void]
      def require_config(*keys)
        @required_configs ||= []
        @required_configs.concat(keys.flatten.map(&:to_sym))
      end

      alias_method :require_configs, :require_config

      # Returns the translation for a key, automatically namespaced to the adapter.
      # @param key [String] The key of the translation.
      # @param hash [Hash] An optional hash of values to be interpolated in the string.
      # @return [String] The translated string.
      def translate(key, hash = {})
        I18n.translate("lita.adapters.#{namespace}.#{key}", hash)
      end

      alias_method :t, :translate
    end

    # @param robot [Lita::Robot] The currently running robot.
    def initialize(robot)
      @robot = robot
      ensure_required_configs
    end

    # @!method join
    # Joins the room with the specified ID.
    # @param room_id [String] The ID of the room.
    # @return [void]
    # @abstract This should be implemented by the adapter.
    # @since 3.0.0

    # @!method part
    # Parts from the room with the specified ID.
    # @param room_id [String] The ID of the room.
    # @return [void]
    # @abstract This should be implemented by the adapter.
    # @since 3.0.0

    # @!method run
    # The main loop. Should connect to the chat service, listen for incoming
    # messages, create {Lita::Message} objects from them, and dispatch them to
    # the robot by calling {Lita::Robot#receive}.
    # @return [void]
    # @abstract This should be implemented by the adapter.

    # @!method send_messages(target, strings)
    # Sends one or more messages to a user or room.
    # @param target [Lita::Source] The user or room to send messages to.
    # @param strings [Array<String>] An array of messages to send.
    # @return [void]
    # @abstract This should be implemented by the adapter.

    # @!method set_topic(target, topic)
    # Sets the topic for a room.
    # @param target [Lita::Source] The room to change the topic for.
    # @param topic [String] The new topic.
    # @return [void]
    # @abstract This should be implemented by the adapter.

    # @!method shut_down
    # Performs any clean up necessary when disconnecting from the chat service.
    # @return [void]
    # @abstract This should be implemented by the adapter.
    [:join, :part, :run, :send_messages, :set_topic, :shut_down].each do |method|
      define_method(method) do |*_args|
        Lita.logger.warn(I18n.t("lita.adapter.method_not_implemented", method: method))
      end
    end

    # Formats a name for "mentioning" a user in a group chat. Override this
    # method in child classes to customize the mention format for the chat
    # service.
    # @param name [String] The name to format as a mention name.
    # @return [String] The formatted mention name.
    # @since 3.1.0
    def mention_format(name)
      "#{name}:"
    end

    # @see .translate
    def translate(*args)
      self.class.translate(*args)
    end

    alias_method :t, :translate

    private

    # Logs a fatal message and aborts if a required config key is not set.
    def ensure_required_configs
      required_configs = self.class.required_configs
      return if required_configs.nil?

      missing_keys = []

      required_configs.each do |key|
        missing_keys << key unless robot.config.adapter[key]
      end

      unless missing_keys.empty?
        Lita.logger.fatal(I18n.t("lita.adapter.missing_configs", configs: missing_keys.join(", ")))
        abort
      end
    end
  end
end

module Lita
  class Handler
    # Methods included in any class that includes at least one type of router.
    # @since 4.0.0
    module Common
      # Adds common functionality to the class and initializes the handler's configuration builder.
      def self.included(klass)
        klass.extend(ClassMethods)
        klass.extend(Namespace)
        klass.extend(Configurable)
        klass.configuration_builder = ConfigurationBuilder.new
      end

      # Common class-level methods for all handlers.
      module ClassMethods
        # Gets (and optionally sets) the directory where the handler's templates are stored.
        # @param path [String] If provided, sets the template root to this value.
        # @return [String] The template root path.
        # @raise [MissingTemplateRootError] If accessed without setting a value first.
        def template_root(path = nil)
          @template_root = path if path

          if defined?(@template_root)
            return @template_root
          else
            raise MissingTemplateRootError
          end
        end

        # Returns the translation for a key, automatically namespaced to the handler.
        # @param key [String] The key of the translation.
        # @param hash [Hash] An optional hash of values to be interpolated in the string.
        # @return [String] The translated string.
        # @since 3.0.0
        def translate(key, hash = {})
          I18n.translate("lita.handlers.#{namespace}.#{key}", hash)
        end

        alias_method :t, :translate
      end

      # A Redis::Namespace scoped to the handler.
      # @return [Redis::Namespace]
      attr_reader :redis

      # The running {Lita::Robot} instance.
      # @return [Lita::Robot]
      attr_reader :robot

      # @param robot [Lita::Robot] The currently running robot.
      def initialize(robot)
        @robot = robot
        @redis = Redis::Namespace.new(redis_namespace, redis: Lita.redis)
      end

      # Invokes the given block after the given number of seconds.
      # @param interval [Integer] The number of seconds to wait before invoking the block.
      # @yieldparam timer [Lita::Timer] The current {Lita::Timer} instance.
      # @return [void]
      # @since 3.0.0
      def after(interval, &block)
        Thread.new { Timer.new(interval: interval, &block).start }
      end

      # The handler's configuration object.
      # @return [Lita::Configuration, Lita::Config] The handler's configuration object.
      # @since 3.2.0
      def config
        if robot.config.handlers.respond_to?(self.class.namespace)
          robot.config.handlers.public_send(self.class.namespace)
        end
      end

      # Invokes the given block repeatedly, waiting the given number of seconds between each
      # invocation.
      # @param interval [Integer] The number of seconds to wait before each invocation of the block.
      # @yieldparam timer [Lita::Timer] The current {Lita::Timer} instance.
      # @return [void]
      # @note The block should call {Lita::Timer#stop} at a terminating condition to avoid infinite
      #   recursion.
      # @since 3.0.0
      def every(interval, &block)
        Thread.new { Timer.new(interval: interval, recurring: true, &block).start }
      end

      # Creates a new +Faraday::Connection+ for making HTTP requests.
      # @param options [Hash] A set of options passed on to Faraday.
      # @yield [builder] A Faraday builder object for adding middleware.
      # @return [Faraday::Connection] The new connection object.
      def http(options = {}, &block)
        options = default_faraday_options.merge(options)

        if block
          Faraday::Connection.new(nil, options, &block)
        else
          Faraday::Connection.new(nil, options)
        end
      end

      # The Lita logger.
      # @return [Lita::Logger] The Lita logger.
      # @since 3.2.0
      def log
        Lita.logger
      end

      def render_template(template_name, variables = {})
        Template.from_file(file_for_template(template_name)).render(variables)
      end

      # @see .translate
      def translate(*args)
        self.class.translate(*args)
      end

      alias_method :t, :translate

      private

      # Default options for new Faraday connections. Sets the user agent to the
      # current version of Lita.
      def default_faraday_options
        { headers: { "User-Agent" => "Lita v#{VERSION}" } }
      end

      def file_for_template(template_name)
        TemplateResolver.new(
          self.class.template_root,
          template_name,
          robot.config.robot.adapter
        ).resolve
      end

      # The handler's namespace for Redis.
      def redis_namespace
        "handlers:#{self.class.namespace}"
      end
    end
  end
end

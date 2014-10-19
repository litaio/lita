module Lita
  # Methods for querying and manipulating authorization groups.
  class Authorization
    # @param config [Lita::Configuration] The configuration object of the currently running robot.
    def initialize(config)
      @config = config
    end

    # Adds a user to an authorization group.
    # @param requesting_user [Lita::User] The user who sent the command.
    # @param user [Lita::User] The user to add to the group.
    # @param group [Symbol, String] The name of the group.
    # @return [Symbol] :unauthorized if the requesting user is not authorized.
    # @return [Boolean] true if the user was added. false if the user was
    #   already in the group.
    def add_user_to_group(requesting_user, user, group)
      return :unauthorized unless user_is_admin?(requesting_user)
      add_user_to_group!(user, group)
    end

    # Adds a user to an authorization group without validating the permissions
    # of the requesting user.
    # @param user [Lita::User] The user to add to the group.
    # @param group [Symbol, String] The name of the group.
    # @return [Boolean] true if the user was added. false if the user was
    #   already in the group.
    # @since 4.0.0
    def add_user_to_group!(user, group)
      redis.sadd(normalize_group(group), user.id)
    end

    # Removes a user from an authorization group.
    # @param requesting_user [Lita::User] The user who sent the command.
    # @param user [Lita::User] The user to remove from the group.
    # @param group [Symbol, String] The name of the group.
    # @return [Symbol] :unauthorized if the requesting user is not authorized.
    # @return [Boolean] true if the user was removed. false if the user was
    #   not in the group.
    def remove_user_from_group(requesting_user, user, group)
      return :unauthorized unless user_is_admin?(requesting_user)
      remove_user_from_group!(user, group)
    end

    # Removes a suer from an authorization group without validating the
    # permissions of the requesting user.
    # @param user [Lita::User] The user to remove from the group.
    # @param group [Symbol, String] The name of the group.
    # @return [Boolean] true if the user was removed. false if the user was
    #   not in the group.
    # @since 4.0.0
    def remove_user_from_group!(user, group)
      redis.srem(normalize_group(group), user.id)
    end

    # Checks if a user is in an authorization group.
    # @param user [Lita::User] The user.
    # @param group [Symbol, String] The name of the group.
    # @return [Boolean] Whether or not the user is in the group.
    def user_in_group?(user, group)
      group = normalize_group(group)
      return user_is_admin?(user) if group == "admins"
      redis.sismember(group, user.id)
    end

    # Checks if a user is an administrator.
    # @param user [Lita::User] The user.
    # @return [Boolean] Whether or not the user is an administrator.
    def user_is_admin?(user)
      Array(@config.robot.admins).include?(user.id)
    end

    # Returns a list of all authorization groups.
    # @return [Array<Symbol>] The names of all authorization groups.
    def groups
      redis.keys("*").map(&:to_sym)
    end

    # Returns a hash of authorization group names and the users in them.
    # @return [Hash] A map of +Symbol+ group names to +Lita::User+ objects.
    def groups_with_users
      groups.reduce({}) do |list, group|
        list[group] = redis.smembers(group).map do |user_id|
          User.find_by_id(user_id)
        end
        list
      end
    end

    private

    # Ensures that group names are stored consistently in Redis.
    def normalize_group(group)
      group.to_s.downcase.strip
    end

    # A Redis::Namespace for authorization data.
    def redis
      @redis ||= Redis::Namespace.new("auth", redis: Lita.redis)
    end

    class << self
      class << self
        private

        # @!macro define_deprecated_class_method
        #   @method $1(*args)
        #   @see #$1
        #   @deprecated Will be removed in Lita 5.0 Use #$1 instead.
        def define_deprecated_class_method(deprecated_method)
          define_method(deprecated_method) do |*args|
            Lita.logger.warn(I18n.t("lita.auth.class_method_deprecated", method: deprecated_method))
            new(Lita.config).public_send(deprecated_method, *args)
          end
        end
      end

      define_deprecated_class_method :add_user_to_group
      define_deprecated_class_method :remove_user_from_group
      define_deprecated_class_method :user_in_group?
      define_deprecated_class_method :user_is_admin?
      define_deprecated_class_method :groups
      define_deprecated_class_method :groups_with_users
    end
  end
end

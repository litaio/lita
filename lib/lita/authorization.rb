# frozen_string_literal: true

require "redis-namespace"

require_relative "user"

module Lita
  # Methods for querying and manipulating authorization groups.
  class Authorization
    # @param robot [Robot] The currently running robot.
    def initialize(robot)
      self.robot = robot
      self.redis = Redis::Namespace.new("auth", redis: robot.redis)
    end

    # Adds a user to an authorization group.
    # @param requesting_user [User] The user who sent the command.
    # @param user [User] The user to add to the group.
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
    # @param user [User] The user to add to the group.
    # @param group [Symbol, String] The name of the group.
    # @return [Boolean] true if the user was added. false if the user was
    #   already in the group.
    # @since 4.0.0
    def add_user_to_group!(user, group)
      redis.sadd(normalize_group(group), user.id)
    end

    # Removes a user from an authorization group.
    # @param requesting_user [User] The user who sent the command.
    # @param user [User] The user to remove from the group.
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
    # @param user [User] The user to remove from the group.
    # @param group [Symbol, String] The name of the group.
    # @return [Boolean] true if the user was removed. false if the user was
    #   not in the group.
    # @since 4.0.0
    def remove_user_from_group!(user, group)
      redis.srem(normalize_group(group), user.id)
    end

    # Checks if a user is in an authorization group.
    # @param user [User] The user.
    # @param group [Symbol, String] The name of the group.
    # @return [Boolean] Whether or not the user is in the group.
    def user_in_group?(user, group)
      group = normalize_group(group)
      return user_is_admin?(user) if group == "admins"

      redis.sismember(group, user.id)
    end

    # Checks if a user is an administrator.
    # @param user [User] The user.
    # @return [Boolean] Whether or not the user is an administrator.
    def user_is_admin?(user)
      Array(robot.config.robot.admins).include?(user.id)
    end

    # Returns a list of all authorization groups.
    # @return [Array<Symbol>] The names of all authorization groups.
    def groups
      redis.keys("*").map(&:to_sym)
    end

    # Returns a hash of authorization group names and the users in them.
    # @return [Hash] A map of +Symbol+ group names to {User} objects.
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

    # @return [Redis::Namespace] A Redis::Namespace for authorization data.
    attr_accessor :redis

    # @return [Robot] The currently running robot.
    attr_accessor :robot
  end
end

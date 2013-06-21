module Lita
  module Authorization
    class << self
      def add_user_to_group(user, group)
        return unless user_is_admin?(user)
        redis.sadd(group, user.id)
      end

      def remove_user_from_group(user, group)
        return unless user_is_admin?(user)
        redis.srem(group, user.id)
      end

      def user_in_group?(user, group)
        redis.sismember(group, user.id)
      end

      def user_is_admin?(user)
        Array(Lita.config.robot.admins).include?(user.id)
      end

      private

      def redis
        @redis ||= Redis::Namespace.new("auth", redis: Lita.redis)
      end
    end
  end
end

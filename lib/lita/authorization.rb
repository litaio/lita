module Lita
  module Authorization
    class << self
      def add_user_to_group(user, group)
        return unless admin?(user)
        redis.sadd(group, user.id)
      end

      def remove_user_from_group(user, group)
        return unless admin?(user)
        redis.srem(group, user.id)
      end

      def user_in_group?(user, group)
        redis.sismember(group, user.id)
      end

      private

      def admin?(user)
        Array(Lita.config.robot.admins).include?(user.id)
      end

      def redis
        @redis ||= Redis::Namespace.new("auth", redis: Lita.redis)
      end
    end
  end
end

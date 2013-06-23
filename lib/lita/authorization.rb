module Lita
  module Authorization
    class << self
      def add_user_to_group(requesting_user, user, group)
        return :unauthorized unless user_is_admin?(requesting_user)
        redis.sadd(normalize_group(group), user.id)
      end

      def remove_user_from_group(requesting_user, user, group)
        return :unauthorized unless user_is_admin?(requesting_user)
        redis.srem(normalize_group(group), user.id)
      end

      def user_in_group?(user, group)
        redis.sismember(normalize_group(group), user.id)
      end

      def user_is_admin?(user)
        Array(Lita.config.robot.admins).include?(user.id)
      end

      private

      def normalize_group(group)
        group.to_s.downcase.strip
      end

      def redis
        @redis ||= Redis::Namespace.new("auth", redis: Lita.redis)
      end
    end
  end
end

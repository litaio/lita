require "redis"
require "json"

module Lita
  class Storage
    REDIS_KEY = "lita:storage"

    def initialize(options = {})
      @redis = Redis.new(options)
      load_data
    end

    def set(key, value)
      @data[key] = value
      save_data
    end

    def get(key)
      @data[key]
    end

    private

    def load_data
      raw_data = @redis.get(REDIS_KEY)

      @data = if raw_data.nil?
        { users: {}, custom_data: {} }
      else
        JSON.parse(raw_data)
      end
    end

    def save_data
      @redis.set(REDIS_KEY, JSON.generate(@data))
    end
  end
end

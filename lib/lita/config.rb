module Lita
  class Config < Hash
    class << self
      def default_config
        c = new
        c.robot = new
        c.robot.name = "Lita"
        c.robot.adapter = :shell
        c.adapter = new
        c.listeners = new
        c
      end
    end

    def []=(key, value)
      super(key.to_sym, value)
    end

    def [](key)
      super(key.to_sym)
    end

    def method_missing(name, *args)
      name_string = name.to_s
      if name_string.chomp!('=')
        self[name_string] = args.first
      else
        self[name]
      end
    end
  end
end

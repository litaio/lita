module Lita
  class Config < Hash
    def self.default_config
      new.tap do |c|
        c.robot = new
        c.robot.name = "Lita"
        c.adapter = new
        c.adapter.name = :shell
        c.listeners = new
        c.commands = new
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
      if name_string.chomp!("=")
        self[name_string] = args.first
      else
        self[name_string]
      end
    end
  end
end

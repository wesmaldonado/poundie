module Poundie
  class Plugin
    def self.list
      @list ||= {}
    end

    def self.active
      @active ||= []
    end

    def self.register(name)
      puts "Registering #{name}: #{self}"
      Poundie::Plugin.list[name] = self
    end

    def self.match(&block)
      define_method(:match?, &block)
    end

    def self.action(&block)
      define_method(:perform, &block)
    end

    def self.prefix(regex, &block)
      match do |message|
        message.body =~ regex
      end

      action do |message|
        instance_exec(message.body.gsub(regex, ''), &block)
      end
    end

    def initialize(room)
      @room = room
    end

    def call(message)
      message = Poundie::Campfire::Message.new(message)
      begin
        match?(message) && perform(message)
      rescue => e
        puts "ERROR: #{e.message}"
        raise e
      end
    end

    private

    def get(url, params={})
      Typhoeus::Request.get(url, params).body
    end

    def post(url, params={})
      Typhoeus::Request.post(url, params).body
    end

    def speak(msg)
      @room.speak(msg)
    end

    def paste(msg)
      @room.paste(msg)
    end

    def tweet(url)
      @room.tweet(url)
    end

    def play(sound)
      @room.play(sound)
    end
  end
end

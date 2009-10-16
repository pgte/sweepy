require 'yaml'

module Sweepy
  module Config
    def self.config
      return @@config if defined? @@config 
      config_file = File.join(RAILS_ROOT, 'config', 'sweepy.yml')
      raise "Copy #{config_file} from vendor/plugins/sweepy/templates/sweepy.yml into config/sweepy.yml and customize it " unless File.exists? config_file
      config = YAML.load_file(config_file)
      environment = (ENV['RAILS_ENV'] or RAILS_ENV)
      raise "Set RAILS_ENV, so sweepy can find the right config file" if not environment
      @@config = config[environment]
      raise "No sweepy configuration for environment #{environment}" if @@config.nil?
      @@config
    end
  end
end
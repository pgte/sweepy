require 'yaml'

module Sweepy
  def self.config
    environment = $ENVIRONMENT || 'development'
    @@config ||= YAML.load_file("config/#{environment}.yml")
  end
end
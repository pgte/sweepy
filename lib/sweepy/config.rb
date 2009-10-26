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
      config = config[environment] || {}
      
      defaults = {
        "persistence" => {
          "timeout_secs"=>1000,
          "persist"=>false,
          "retry_after_secs"=>10,
          "peers"=>[]
        },
       "sweeping" => {
         "fragments" => {
           "base_dir"=>File.join(RAILS_ROOT, 'tmp', 'cache')
         },
         "pages" => {
           "allowed_paths"=>[],
           "base_dir"=>File.join(RAILS_ROOT, 'public')
         }
        },
        "servers" => {
           "public" => {
             "port"=>10001,
             "bind_address"=>"0.0.0.0"
           },
           "private" => {
             "port"=>10002
           },
           "broadcast" => {
             "port"=>10000,
             "bind_address" => "255.255.255.255"
           },
           "admin" => {
             "port" => 10003,
             "bind_address" => 
             "0.0.0.0"
           }
        }
      }
       
      
      merger = proc { |key,v1,v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      config = defaults.merge(config, &merger)
      @@config = config

    end
  end
end
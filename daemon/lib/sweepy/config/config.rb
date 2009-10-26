require 'yaml'

module Sweepy
  class ConfigurationException < Exception
    
  end
  
  def self.config
    environment = $ENVIRONMENT || 'development'
    return @@config if defined? @@config
    
    base_dir = File.expand_path(File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', '..', '..', '..', '..', '..'))
    defaults = {
      "persistence" => {
        "timeout_secs"=>1000,
        "persist"=>false,
        "retry_after_secs"=>10,
        "peers"=>[]
       },
       "sweeping" => {
         "fragments" => {
           "base_dir"=>File.join(base_dir, 'tmp', 'cache')
         },
         "pages" => {
           "allowed_paths"=>[],
           "base_dir"=>File.join(base_dir, 'public')
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
    
    config = YAML.load_file(File.join(File.dirname(__FILE__), '..', '..', '..','..','..','..','..','config', "sweepy.yml"))
    config = config[environment] || {}
    merger = proc { |key,v1,v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    config = defaults.merge(config, &merger)
    @@config = config
  end
  
end
module Sweepy
  class Stats
    
    VARIABLES = [:sweep_broadcasts,  :sweeps, :sweep_pages, :sweep_fragments, :swepts]
    
    def initialize
      VARIABLES.each do |var|
        instance_variable_set("@#{var}", 0)
      end
    end
    
    VARIABLES.each do |var|
      define_method("#{var}_incr") do
        instance_variable_set("@#{var}", instance_variable_get("@#{var}") + 1)
      end
      attr_reader var
    end
    
    
  end
end
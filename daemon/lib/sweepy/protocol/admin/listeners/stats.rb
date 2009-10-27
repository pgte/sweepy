module Sweepy
  module Protocol
    module Admin
      module Listeners
        class Stats < Sweepy::Protocol::Listener
          
          def register(registry)
            registry.register_for_command('STATS', self)
          end
      
          def command(arguments, source)
            send_data "SWEEPBROADCASTS: #{$STATS.sweep_broadcasts}\nSWEEPS: #{$STATS.sweeps}\nSWEEP_PAGES: #{$STATS.sweep_pages}\nSWEEP_FRAGMENTS: #{$STATS.sweep_fragments}\nSWEPTS: #{$STATS.swepts}\n"
          end
    
        end
      end
    end
  end
end
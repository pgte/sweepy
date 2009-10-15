module Sweepy
  module Protocol
    module Public
      module Listeners
        class Pong < Sweepy::Protocol::Listener
          
          def register(registry)
            registry.register_for_command('PONG', self)
          end
      
          def command(arguments, source_ip)
            puts "PONG command received from #{source_ip}"
          end
    
        end
      end
    end
  end
end
module Sweepy
  module Protocol
    module Broadcast
      module Listeners
        class Ping < Sweepy::Protocol::Listener
          
          def register(registry)
            registry.register_for_command('PING', self)
          end
      
          def command(arguments, source_ip)
            puts "PING command received from #{source_ip}"
            #send_to source_ip, "PONG"
            send_to '127.0.0.1', "PONG"
          end
    
        end
      end
    end
  end
end
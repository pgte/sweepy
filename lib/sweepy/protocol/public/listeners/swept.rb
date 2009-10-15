module Sweepy
  module Protocol
    module Public
      module Listeners
        class Swept < Sweepy::Protocol::Listener
          
          def register(registry)
            registry.register_for_command('SWEPT', self)
          end
      
          def command(arguments, source)
            puts "SWEPT command received from #{source}"
            if Sweepy.config['persistence']['persist']
              nonce = arguments[0]
              key = "#{nonce}-#{source}"
              if value = $PM.get(key)
                puts "deleting #{value}"
                $PM.delete(key)
              end
            end
          end
    
        end
      end
    end
  end
end
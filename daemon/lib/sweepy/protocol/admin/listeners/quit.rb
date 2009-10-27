module Sweepy
  module Protocol
    module Admin
      module Listeners
        class Quit < Sweepy::Protocol::Listener
          
          def register(registry)
            registry.register_for_command('QUIT', self)
          end
      
          def command(arguments, source)
            send_data "Goodbye\n"
            close_connection_after_writing
          end
    
        end
      end
    end
  end
end
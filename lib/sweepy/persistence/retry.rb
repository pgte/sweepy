require 'lib/sweepy/protocol/listener'


module Sweepy
  module Persistence
    class Retry < Sweepy::Protocol::Listener
    
      def retry
        puts "#"
        $PM.iterinit
        while key = $PM.iternext
          _process_message(key)
        end
      end
      
      private
      
      def _process_message(key)
        nounce, dest = key.split('-')
        unless Sweepy.config['persistence']['peers'].include? dest
          # IP address is no longer
          puts "Peer \"#{dest}\" no longer here. Deleting it" 
          $PM.delete(key)
        else
          message = $PM.get(key)
          if(message)
            message = message.split(' ')
            timestamp = message[0].to_i
            if timestamp + Sweepy.config['persistence']['timeout_secs'] < Time.now.utc.to_i
              # message has expired. delete it
              puts "Message \"#{key}\" expired. Deleting it" 
              $PM.delete(key)
            else
              #resend message  
              send_to(dest, message[1..-1].join(' '))
            end
          end
        end
      end
    end
  end
end
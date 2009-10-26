require 'sweepy/protocol/listener'


module Sweepy
  module Persistence
    class Retry < Sweepy::Protocol::Listener
    
      def retry
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
          Sweepy.log "Peer \"#{dest}\" no longer here. Deleting it" 
          $PM.delete(key)
        else
          message = $PM.get(key)
          if(message)
            message = message.split(' ')
            timestamp = message[0].to_i
            if timestamp + Sweepy.config['persistence']['timeout_secs'] < Time.now.utc.to_i
              # message has expired. delete it
              Sweepy.log "Message \"#{key}\" expired. Deleting it" 
              $PM.delete(key)
            else
              #resend message
              command = message[1..-1].join(' ')
              Sweepy.log "retrying to send \"#{command}\" to #{dest}"   
              send_to(dest, command)
            end
          end
        end
      end
    end
  end
end
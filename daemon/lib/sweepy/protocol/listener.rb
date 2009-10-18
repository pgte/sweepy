module Sweepy
  module Protocol
    class Listener
      
      def initialize(messenger)
        @messenger = messenger
      end
      
      attr_reader :messenger
      
      def send_to(to, command, arguments = [])
        _send_message(to, command, arguments)
      end
      
      def send_broadcast(command, arguments = [])
        _send_message(nil, command, arguments)
      end
      
      private
      
      def _send_message(to, command, arguments = [])
        @messenger.send_message(to, command, arguments)
        #puts "sending #{command} to #{to} with arguments \"#{arguments.join(" ")}\""
        #@messenger.send_datagram("#{command} #{arguments.join(" ")}", to, Sweepy.config[to.nil? ? 'broadcast' : 'public']['port'])        
      end
      
      def send_data(data)
        @messenger.send_data(data)
      end
      
      def close_connection_after_writing
        @messenger.close_connection_after_writing
      end
      
      
    end
  end
end
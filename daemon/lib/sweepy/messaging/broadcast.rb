require 'sweepy/messaging/base'

module Sweepy
  module Messaging
    class Broadcast < Sweepy::Messaging::Base
      
      def sweepy_post_init
        register_listeners('sweepy/protocol/broadcast/listeners', 'Sweepy::Protocol::Broadcast::Listeners')
      end      

    end    
  end
end


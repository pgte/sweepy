require 'lib/sweepy/messaging/base'

module Sweepy
  module Messaging
    class Public < Sweepy::Messaging::Base
      
      def sweepy_post_init
        register_listeners('lib/sweepy/protocol/public/listeners', 'Sweepy::Protocol::Public::Listeners')
      end
      
    end    
  end
end


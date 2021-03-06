require 'sweepy/messaging/base'

module Sweepy
  module Messaging
    class Private < Sweepy::Messaging::Base
      
      def sweepy_post_init
        register_listeners('sweepy/protocol/private/listeners', 'Sweepy::Protocol::Private::Listeners')
      end
      
    end    
  end
end


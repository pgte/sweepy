require 'lib/sweepy/messaging/base'

module Sweepy
  module Messaging
    class Private < Sweepy::Messaging::Base
      
      def sweepy_post_init
        register_listeners('lib/sweepy/protocol/private/listeners', 'Sweepy::Protocol::Private::Listeners')
      end
      
    end    
  end
end


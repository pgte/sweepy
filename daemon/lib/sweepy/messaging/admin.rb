require 'sweepy/messaging/base'

module Sweepy
  module Messaging
    class Admin  < Sweepy::Messaging::Base
      
      def sweepy_post_init
        register_listeners('sweepy/protocol/admin/listeners', 'Sweepy::Protocol::Admin::Listeners')
      end
      
    end    
  end
end


require 'lib/sweepy/messaging/base'

module Sweepy
  module Messaging
    class Admin  < Sweepy::Messaging::Base
      
      def sweepy_post_init
        register_listeners('lib/sweepy/protocol/admin/listeners', 'Sweepy::Protocol::Admin::Listeners')
      end
      
    end    
  end
end


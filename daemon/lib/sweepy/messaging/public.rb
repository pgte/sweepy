require 'lib/sweepy/messaging/base'

module Sweepy
  module Messaging
    class Public < Sweepy::Messaging::Base
      
      def sweepy_post_init
        register_listeners('lib/sweepy/protocol/public/listeners', 'Sweepy::Protocol::Public::Listeners')
        
        if !defined?(@@retrier) && Sweepy.config['persistence']['persist']
          @@retrier = Sweepy::Persistence::Retry.new(self) 
          EM::add_periodic_timer(Sweepy.config['persistence']['retry_after_secs']) {
            @@retrier.retry
          }
        end
        
      end
      
    end    
  end
end


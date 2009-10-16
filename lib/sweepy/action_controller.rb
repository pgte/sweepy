module Sweepy
  module ActionController
    
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class << self
          alias_method_chain :expire_page, :sweepy
        end
      end
    end
    
    module ClassMethods

      def expire_page_with_sweepy(path)
        logger.debug("SWEEPY: expire_page_with_sweepy(#{path})")
        Sweepy::Commander.sweepbroadcast(path)
        expire_page_without_sweepy(path)
      end

    end
    
  end
end
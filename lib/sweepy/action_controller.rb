module Sweepy
  module ActionController
    
    def self.included(base)
      base.extend ClassMethods
      base.send (:include, InstanceMethods)
      base.class_eval do
        class << self
          alias_method_chain :expire_page, :sweepy
        end
        alias_method_chain :expire_fragment, :sweepy
      end
    end
    
    module ClassMethods

      def expire_page_with_sweepy(path)
        logger.debug("SWEEPY: expire_page_with_sweepy(#{path})")
        Sweepy::Commander.sweep_page_broadcast(path)
        expire_page_without_sweepy(path)
      end
    end
    
    module InstanceMethods
      
      def expire_fragment_with_sweepy(key, options = {})
        key = key.is_a?(Regexp) ? key : fragment_cache_key(key)
        logger.debug("SWEEPY: expire_fragment_with_sweepy(#{key.inspect}, #{options.inspect})")
        Sweepy::Commander.sweep_fragment_broadcast(key)
        expire_fragment_without_sweepy(key, options)
      end

    end
    
  end
end
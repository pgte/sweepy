module Sweepy
  module Persistence
    module SelfPublicAddress
      def self.get
        
        if !defined? @@local_ip
          local_ip = nil
          require 'socket'
          orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily  
          
          begin       
            UDPSocket.open do |s|  
              s.connect '64.233.187.99', 1  
              local_ip = s.addr.last  
            end  
            @@local_ip = local_ip
          ensure  
            Socket.do_not_reverse_lookup = orig
          end
       else
         @@local_ip
       end
      end
    end
  end
  

end
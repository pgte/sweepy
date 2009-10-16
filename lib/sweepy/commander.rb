require 'socket'
module Sweepy
  class Commander
    
    def self.sweepbroadcast(path)
      sock = UDPSocket.open
      begin
        sock.send("SWEEPBROADCAST #{path}", 0, '127.0.0.1', Sweepy::Config.config['daemon']['private']['port'])
      ensure
        sock.close if sock
      end
      
    end

  end
end
require 'socket'
module Sweepy
  class Commander
    
    def self.sweepbroadcast(path)
      _send_command "SWEEPBROADCAST #{path}"
    end
    
    private
    
    def self._send_command(command)
      sock = UDPSocket.open
      begin
        port = Integer(Sweepy::Config.config['daemon']['private']['port'])
        sock.send(command+"\n", 0, '127.0.0.1', port)
        RAILS_DEFAULT_LOGGER.debug("SWEEPY: sent command #{command} on port #{port}")
      ensure
        sock.close if sock
      end
    end

  end
end
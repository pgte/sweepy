require 'socket'
module Sweepy
  class Commander
    
    def self.sweep_page_broadcast(path)
      _send_command "SWEEPBROADCAST PAGE #{path}"
    end

    def self.sweep_fragment_broadcast(path)
      if path.is_a?(Regexp)
        _send_command "SWEEPBROADCAST FRAGMENT_REGEXP #{path.options.to_s} #{path.source}"
      else
      _send_command "SWEEPBROADCAST FRAGMENT_STRING #{path}"
      end
    end

    private
    
    def self._send_command(command)
      sock = UDPSocket.open
      begin
        port = Integer(Sweepy::Config.config['servers']['private']['port'])
        sock.send(command+"\n", 0, '127.0.0.1', port)
        RAILS_DEFAULT_LOGGER.debug("SWEEPY: sent command #{command} on port #{port}")
      ensure
        sock.close if sock
      end
    end

  end
end
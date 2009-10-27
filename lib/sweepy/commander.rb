require 'socket'
require 'digest/sha1'

module Sweepy
  class Commander
    
    def self.sweep_page_broadcast(path)
      if path.is_a?(Regexp)
        command = "PAGE_REGEXP #{path.options.to_s} #{path.source}"
        if(Sweepy::Config.config['persistence']['persist'])
          _send_command "SWEEPBROADCAST #{command}"
        else
          _send_command "SWEEP #{_nonce} #{command}", true
        end
      else
        command = "PAGE_STRING #{path}"
        if(Sweepy::Config.config['persistence']['persist'])
          _send_command "SWEEPBROADCAST #{command}"
        else
          _send_command "SWEEP #{_nonce} #{command}", true
        end
      end
    end

    def self.sweep_fragment_broadcast(path)
      if path.is_a?(Regexp)
        command = "FRAGMENT_REGEXP #{path.options.to_s} #{path.source}"
        if(Sweepy::Config.config['persistence']['persist'])
          _send_command "SWEEPBROADCAST #{command}"
        else
          _send_command "SWEEP #{_nonce} #{command}", true
        end
      else
        command = "FRAGMENT_STRING #{path}"
        if(Sweepy::Config.config['persistence']['persist'])
          _send_command "SWEEPBROADCAST #{command}"
        else
          _send_command "SWEEP #{_nonce} #{command}", true
        end
      end
    end

    private
    
    def self._nonce
      Digest::SHA1.hexdigest Time.now.to_s+rand(1000000).to_s
    end
    
    def self._send_command(command, broadcast = false)
      sock = UDPSocket.open
      begin
        port = Integer(broadcast ? Sweepy::Config.config['servers']['broadcast']['port'] : Sweepy::Config.config['servers']['private']['port'])
        sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true) if broadcast
        sock.send(command+"\n", 0, (broadcast ? Sweepy::Config.config['servers']['broadcast']['bind_address'] : '127.0.0.1'), port)
        RAILS_DEFAULT_LOGGER.debug("SWEEPY: sent command #{command} on port #{port}")
      ensure
        sock.close if sock
      end
    end

  end
end
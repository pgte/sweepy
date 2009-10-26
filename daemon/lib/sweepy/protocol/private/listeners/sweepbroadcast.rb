require 'digest/sha1'

module Sweepy
  module Protocol
    module Private
      module Listeners
        class Sweepbroadcast < Sweepy::Protocol::Listener
          
          def register(registry)
            registry.register_for_command('SWEEPBROADCAST', self)
          end
      
          def command(arguments, source)
            $STATS.sweep_broadcasts_incr
            Sweepy.log "SWEEPBROADCAST command received from #{source}"
            _sweepbroadcast(arguments)
          end
          
          private
          
          def _sweepbroadcast(paths)
            nonce = _nonce
            sweep_command = "SWEEP #{nonce} #{paths.join(" ")}"
            if Sweepy.config['persistence']['persist']
              Sweepy.config['persistence']['peers'].each do |peer|
                if peer != Sweepy::Persistence::SelfPublicAddress.get
                  $PM.put("#{nonce}-#{peer}", "#{Time.now.utc.to_i} #{sweep_command}")
                end
              end
            end
            send_to nil, sweep_command
          end
          
          def _nonce
            Digest::SHA1.hexdigest Time.now.to_s+rand(1000000).to_s
          end
    
        end
      end
    end
  end
end
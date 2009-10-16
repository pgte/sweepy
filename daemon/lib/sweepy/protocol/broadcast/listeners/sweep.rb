module Sweepy
  module Protocol
    module Broadcast
      module Listeners
        class Sweep < Sweepy::Protocol::Listener
          
          def register(registry)
            registry.register_for_command('SWEEP', self)
          end
      
          def command(arguments, source)
            puts "SWEEP command received from #{source}"
            nonce = arguments[0] 
            arguments[1..-1].each do |path|
              _sweep(path, source)
            end
            send_to(source, "SWEPT #{nonce}")
          end
          
          private
          
          def _sweep(path, source)
            base_dir = File.expand_path(Sweepy.config['sweeping']['base_dir'])
            path = File.expand_path(File.join(base_dir, path), base_dir)
            allowed = false
            if (path =~ /#{base_dir}/) == 0
              allowed = true
              if allowed_paths = Sweepy.config['sweeping']['allowed_paths']
                allowed = false
                allowed_paths.each do |allowed_path|
                  if File.fnmatch(File.join(base_dir, allowed_path), path)
                    allowed = true
                    break
                  end
                end
              end
              
            else
              puts "Security Warning: #{source} tried to remove out of path: #{path}"
            end
            if allowed
              puts "Removing #{path}"
              FileUtils.remove_entry_secure(path, true)
            else
              puts "Security Warning: #{source} tried to remove #{path}"
            end
          end
    
        end
      end
    end
  end
end
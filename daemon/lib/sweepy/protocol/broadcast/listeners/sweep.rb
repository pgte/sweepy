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
            type = arguments[1]
            path_start_on_index = 2
            regexp_options = nil
            if type == 'FRAGMENT_REGEXP'
              regexp_options = Integer(arguments[2])
              path_start_on_index = 3
            end
            arguments[path_start_on_index..-1].each do |path|
              case type
                when 'PAGE'
                  _sweep_page(path, source)
                when 'FRAGMENT_REGEXP'
                  _sweep_fragment_regexp(path, regexp_options, source)
                when 'FRAGMENT_STRING'
                  _sweep_fragment(path, source)
                else
                  raise "Unknown sweep command type #{type}"
              end
            end
            send_to(source, "SWEPT #{nonce}")
          end
          
          private

          def _sweep_fragment_regexp(path, regexp_options, source)
            puts "_sweep_fragment_regexp(#{path.inspect}, #{regexp_options.inspect}, #{source})"
            regexp = Regexp.new(path, regexp_options)
            puts "regexp = #{regexp.inspect}"
          end

          def _sweep_fragment(path, source)
            puts "_sweep_fragment(#{path.inspect}, #{source})"
          end

          def _sweep_page(path, source)
            puts "_sweep_page(#{path.inspect}, #{source})"
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
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
            base_dir = File.expand_path(Sweepy.config['sweeping']['fragments']['base_dir'])
            puts "base_dir: #{base_dir}"
            matcher = Regexp.new(path, regexp_options)
            puts "regexp = #{matcher.inspect}"
            search_dir(base_dir) do |f|
              if f =~ matcher
                begin
                  puts "(1)removing #{path}"
                  File.delete(f)
                rescue SystemCallError => e
                  # If there's no cache, then there's nothing to complain about
                end
              end
            end
          end

          def _sweep_fragment(path, source)
            puts "_sweep_fragment(#{path.inspect}, #{source})"
            base_dir = File.expand_path(Sweepy.config['sweeping']['fragments']['base_dir'])
            path = File.expand_path(File.join(base_dir, path), base_dir)
            if (path =~ /#{base_dir}/) == 0
              puts "(2)removing #{path}"
              begin
                File.delete(path) if File              
              rescue SystemCallError => e
                # If there's no cache, then there's nothing to complain about
              end
            else
              puts "Security Warning: #{source} tried to remove out of path: #{path}"
            end
          end

          def _sweep_page(path, source)
            puts "_sweep_page(#{path.inspect}, #{source})"
            base_dir = File.expand_path(Sweepy.config['sweeping']['pages']['base_dir'])
            path = File.expand_path(File.join(base_dir, path), base_dir)
            allowed = false
            if (path =~ /#{base_dir}/) == 0
              allowed = true
              if allowed_paths = Sweepy.config['sweeping']['pages']['allowed_paths']
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
              puts "(3)removing #{path}"
              File.delete(path)
            else
              puts "Security Warning: #{source} tried to remove #{path}"
            end
          end
          
          private
          
            def search_dir(dir, &callback)
              Dir.foreach(dir) do |d|
                next if d == "." || d == ".."
                name = File.join(dir, d)
                if File.directory?(name)
                  search_dir(name, &callback)
                else
                  callback.call name
                end
              end
            end
    
        end
  
      end
    end
  end
end
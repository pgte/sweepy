require 'uri'

module Sweepy
  module Protocol
    module Broadcast
      module Listeners
        class Sweep < Sweepy::Protocol::Listener
          
          def register(registry)
            registry.register_for_command('SWEEP', self)
          end
      
          def command(arguments, source)
            $STATS.sweeps_incr
            Sweepy.log "SWEEP command received from #{source}"
            nonce = arguments[0]
            begin
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
            ensure
              send_to(source, "SWEPT #{nonce}")
            end
          end
          
          private

          def _sweep_fragment_regexp(path, regexp_options, source)
            $STATS.sweep_fragments_incr
            Sweepy.log "_sweep_fragment_regexp(#{path.inspect}, #{regexp_options.inspect}, #{source})"
            base_dir = File.expand_path(Sweepy.config['sweeping']['fragments']['base_dir'])
            Sweepy.log "base_dir: #{base_dir}"
            matcher = Regexp.new(path, regexp_options)
            Sweepy.log "regexp = #{matcher.inspect}"
            search_dir(base_dir) do |f|
              if f =~ matcher
                begin
                  File.delete(f)
                rescue SystemCallError => e
                  # If there's no cache, then there's nothing to complain about
                end
              end
            end
          end

          def _sweep_fragment(path, source)
            $STATS.sweep_fragments_incr
            Sweepy.log "_sweep_fragment(#{path.inspect}, #{source})"
            base_dir = File.expand_path(Sweepy.config['sweeping']['fragments']['base_dir'])
            path = File.expand_path(File.join(base_dir, path), base_dir)
            if (path =~ /#{base_dir}/) == 0
              begin
                File.delete(fragment_real_file_path(path)) if File              
              rescue SystemCallError => e
                # If there's no cache, then there's nothing to complain about
              end
            else
              Sweepy.err "Security Warning: #{source} tried to remove out of path: #{path}"
            end
          end

          def _sweep_page(path, source)
            $STATS.sweep_pages_incr
            Sweepy.log "_sweep_page(#{path.inspect}, #{source})"
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
              Sweepy.err "Security Warning: #{source} tried to remove out of path: #{path}"
            end
            if allowed
              Sweepy.log "(3)removing #{path}"
              begin
                cache_file_name = page_cache_file(path) 
                File.delete(cache_file_name) if File.exists? cache_file_name
              rescue SystemCallError => e
                # If there's no cache, then there's nothing to complain about
              end
            else
              Sweepy.err "Security Warning: #{source} tried to remove #{path}"
            end
          end
          
          private
          
          def fragment_real_file_path(name)
            '%s/%s.cache' % [@cache_path, name.gsub('?', '.').gsub(':', '.')]
          end

          
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
        
          def page_cache_file(path)
            name = (path.empty? || path == "/") ? "/index" : URI.unescape(path.chomp('/'))
            name << '.html' unless (name.split('/').last || name).include? '.'
            return name
          end

    
        end
  
      end
    end
  end
end
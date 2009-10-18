require 'rubygems'
require 'eventmachine'
require 'socket'

require 'lib/sweepy/persistence/message'
require 'lib/sweepy/protocol/listener'

module Sweepy
  module Messaging
    class Base < EventMachine::Protocols::LineAndTextProtocol 
      
      def post_init
        @command_listeners = {}

        sweepy_post_init
        
      end
      
      def register_for_command(command, listener)
        puts "#{listener.class} registred for \"#{command}\" command"
        @command_listeners[command] = listener
      end      

      def receive_line line
        begin
          #p "line: #{line}"
          port, ip = Socket.unpack_sockaddr_in(get_peername)
          #p "from #{ip}"

          tokens = line.split(" ")
          command = tokens.first
          if listener = @command_listeners[command]
            listener.command(tokens[1..-1], ip)
          else
            raise "No listener found for command \"#{command}\""
          end
          #p "last message from this ip was #{@db.get ip}"
          #@db.put(ip, line)
          #close_connection if data =~ /quit/i
        rescue => exception
          send_data exception.message+"\n"
          $stderr.puts "Error processing protocol line: #{exception.message}\nBacktrace:\n#{exception.backtrace.join("\n")}\n"
        end
      end
      
      def send_message(to, command, arguments = [])
        data = "#{command} #{arguments.join(" ")}\n"
        port = Sweepy.config['servers'][to.nil? ? 'broadcast' : 'public']['port']
        to = Sweepy.config['servers']['broadcast']['bind_address'] if to.nil?
        #puts "send_datagram(#{data}, #{to}, #{port})"
        send_datagram(data, to, port)
      end

      protected
      
      def register_listeners(base_path, module_name)
         puts "Checking for listeners on #{base_path}"
         Dir["#{base_path}/*.rb"].each do |listener_file|
           puts "Registering #{listener_file}"
          listener_file.gsub!(/\.rb$/, '')
          puts "registering #{listener_file}"
          require listener_file
          listener_class_name = listener_file.split("/").last.capitalize
          begin
            listener = eval "#{module_name}::#{listener_class_name}.new(self)"
            listener.register(self)
          rescue => exc
            puts "Error registering listener from #{listener_file}: #{exc.to_s}\nBacktrace:\n#{exc.backtrace.join("\n")}"
          end
        end

      end
 
    end
  end
    
end
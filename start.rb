require 'rubygems'
require 'eventmachine'

require 'lib/sweepy/config/config'
require 'lib/sweepy/messaging/broadcast'
require 'lib/sweepy/messaging/public'

puts "Configuration:\n#{Sweepy.config.inspect}"

## Start public server
EM.run { 
  begin
    puts "Starting public server on #{Sweepy.config['servers']['public']['bind_address']}:#{Sweepy.config['servers']['public']['port']}"
    EM.open_datagram_socket Sweepy.config['servers']['public']['bind_address'], Sweepy.config['servers']['public']['port'], Sweepy::Messaging::Public 
    puts "Starting broadcast server on #{Sweepy.config['servers']['broadcast']['bind_address']}:#{Sweepy.config['servers']['broadcast']['port']}"
    EM.open_datagram_socket Sweepy.config['servers']['broadcast']['bind_address'], Sweepy.config['servers']['broadcast']['port'], Sweepy::Messaging::Broadcast
  rescue => exc
    puts "Error starting services: #{exc.message}\nBacktrace:\n#{exc.backtrace.join("\n")}"
    exit
  end
}

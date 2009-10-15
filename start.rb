require 'rubygems'
require 'eventmachine'

require 'lib/sweepy/config/config'
require 'lib/sweepy/messaging/broadcast'
require 'lib/sweepy/messaging/public'
require 'lib/sweepy/messaging/private'
require 'lib/sweepy/persistence/self_public_address'

puts "Configuration:\n#{Sweepy.config.inspect}"

## Start persistence

if Sweepy.config['persistence']['persist']
  require 'lib/sweepy/persistence/message'
  $PM = Sweepy::Persistence::Message.new('db.tch')
  $PM.connect
end

## Start public server
EM.run { 
  begin
    puts "Starting public server on #{Sweepy.config['servers']['public']['bind_address']}:#{Sweepy.config['servers']['public']['port']}"
    EM.open_datagram_socket Sweepy.config['servers']['public']['bind_address'], Sweepy.config['servers']['public']['port'], Sweepy::Messaging::Public 
    puts "Starting broadcast server on #{Sweepy.config['servers']['broadcast']['bind_address']}:#{Sweepy.config['servers']['broadcast']['port']}"
    EM.open_datagram_socket Sweepy.config['servers']['broadcast']['bind_address'], Sweepy.config['servers']['broadcast']['port'], Sweepy::Messaging::Broadcast
    puts "Starting private server on port #{Sweepy.config['servers']['private']['port']}"
    EM.open_datagram_socket '127.0.0.1', Sweepy.config['servers']['private']['port'], Sweepy::Messaging::Private
  rescue => exc
    puts "Error starting services: #{exc.message}\nBacktrace:\n#{exc.backtrace.join("\n")}"
    exit
  end
}

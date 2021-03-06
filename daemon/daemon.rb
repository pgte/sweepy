environment = ENV['RAILS_ENV'] || 'development'

puts "starting #{environment} environment..."

begin
  require 'eventmachine'
rescue LoadError
  $stderr.puts "\"eventmachine\" gem not detected. Please install it using\n\tsudo gem install eventmachine"
  exit
end

require 'sweepy/logger'
require 'sweepy/config/config'
require 'sweepy/messaging/broadcast'
require 'sweepy/messaging/public'
require 'sweepy/messaging/private'
require 'sweepy/messaging/admin'
require 'sweepy/persistence/self_public_address'

require 'sweepy/stats/stats'

Sweepy.log "Configuration:\n#{Sweepy.config.inspect}"

## Start persistence

$PM = nil
if Sweepy.config['persistence']['persist']
  require 'sweepy/persistence/message'
  require 'sweepy/persistence/retry'
  $PM = Sweepy::Persistence::Message.new(File.expand_path(File.join(File.expand_path(File.dirname(__FILE__)), 'database', "#{environment}.tch")))
  $PM.connect
end

## Start stats

$STATS = Sweepy::Stats.new 

## Start public server
begin
EM.run {

  begin
    
    Sweepy.log "Starting public server on #{Sweepy.config['servers']['public']['bind_address']}:#{Sweepy.config['servers']['public']['port']}"
    EM.open_datagram_socket Sweepy.config['servers']['public']['bind_address'], Sweepy.config['servers']['public']['port'], Sweepy::Messaging::Public 
    Sweepy.log "Starting broadcast server on #{Sweepy.config['servers']['broadcast']['bind_address']}:#{Sweepy.config['servers']['broadcast']['port']}"
    EM.open_datagram_socket Sweepy.config['servers']['broadcast']['bind_address'], Sweepy.config['servers']['broadcast']['port'], Sweepy::Messaging::Broadcast
    Sweepy.log "Starting private server on port #{Sweepy.config['servers']['private']['port']}"
    EM.open_datagram_socket '127.0.0.1', Sweepy.config['servers']['private']['port'], Sweepy::Messaging::Private
    if Choice.choices.admin
      Sweepy.log "Starting admin server"    
      EM.start_server Sweepy.config['servers']['admin']['bind_address'], Sweepy.config['servers']['admin']['port'], Sweepy::Messaging::Admin
    end
  rescue => exc
    Sweepy.err "Error starting services: #{exc.message}\nBacktrace:\n#{exc.backtrace.join("\n")}"
    exit
  end
}
rescue Interrupt
  Sweepy.log 'Closing...'
ensure
  puts "closing the DM"
  $PM.disconnect unless $PM.nil? 
end
  Sweepy.log 'Closed.'

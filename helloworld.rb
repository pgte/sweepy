require 'rubygems'
require 'eventmachine'
require 'socket'

require 'lib/sweepy/persistence/message'

class Echo < EventMachine::Protocols::LineAndTextProtocol
  
  def initialize
    @db = Sweepy::Persistence::Message.new('db.tch')
    @db.connect
    super
  end
  
  def receive_line line
    begin
      p "line: #{line}"
      port, ip = Socket.unpack_sockaddr_in(get_peername)
      p "from #{ip}"
      p "last message from this ip was #{@db.get ip}"
      @db.put(ip, line)
      #close_connection if data =~ /quit/i
    rescue => exception
      puts exception.to_s
    end
  end
end

EM.run {
  EM.open_datagram_socket "192.168.2.255", 10000, Echo
}

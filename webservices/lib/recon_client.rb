require 'ostruct'
require 'socket'
require File.dirname(__FILE__) + '/name'

class Object
   def blank?
     respond_to?(:empty?) ? empty? : !self
   end
end

class ReconicliationClient
  def initialize(host = 'localhost', port = 1234)
    @host = host
    @port = port
    socket
  end

  def get(data)
    socket.write data
    # socket.puts data
    output = ""
    while !socket.eof? do
      output = output + socket.read(1024)
    end
  
    socket.close 

    @matches = output.gsub("\t","\n") #if output
    
  end

  alias_method :find, :get

  def socket
    @socket ||= TCPSocket.open @host, @port
  end
  
end
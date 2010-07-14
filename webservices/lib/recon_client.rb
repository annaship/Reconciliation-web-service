require 'ostruct'
require 'socket'
require File.dirname(__FILE__) + '/name'
require File.dirname(__FILE__) + '/app_lib.rb'
require 'yaml'

class Object
   def blank?
     respond_to?(:empty?) ? empty? : !self
   end
end

class ReconicliationClient
  def initialize(host = 'localhost', port = 3002)
    @host = host
    @port = port
    socket
  end

  def get(data)
    # socket.write data
    # socket.puts data
    data_length = data.length
    socket.write("Content-length: #{data_length}\r\n")
    socket.write(data)
    socket.flush

    # output = ""
    # while !socket.eof? do
    #   output = output + socket.read(1024)
    # end
    output = socket.read(data_length)
    socket.close 

    # current_pos = 1
    # names_arr   = []
    @matches = output
    # .gsub("\t","\n") #if output
    # @matches.each do |name|
    #   name = name.strip
    #   current_pos += name.size
    #   a_name = Name.new(name, "", current_pos) unless name.blank?
    #   names_arr << a_name
    # end

    # file_outp = File.open("/Users/anna/work/reconcile-app/webservices/texts/output_check.txt", 'w')
    # file_outp.print(@matches.inspect.to_s)
    # file_outp.close
    # 

    # @matches = names_arr
    # 
    return @matches 
    
    
  end

  alias_method :match, :get

  def socket
    @socket ||= TCPSocket.open @host, @port
  end
  
end
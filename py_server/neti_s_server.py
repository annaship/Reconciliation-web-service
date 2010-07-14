import SocketServer
import time
import gobject, socket

total_data = []
t1 = time.clock()
from netineti import *
print "Initializing... model training..."
NN = NetiNetiTrain("species_train.txt")
# NN = NetiNetiTrain()
nf = nameFinder(NN)
t2 = time.clock()
t = t2 - t1
# print t
t = t / 60
print "...model ready in %s min." % t
t2 = 0
t = 0

class MyTCPHandler(SocketServer.StreamRequestHandler):
	#     """
	#     It is instantiated once per connection to the server, and must
	#     override the handle() method to implement communication to the
	#     client.
	#     """
	
    def handle(self):
        # self.request is the TCP socket connected to the client
        total_data = []
        conn = self.request
        conn_name = conn.getpeername()

        print "Connected %s" % conn_name[1]
        while 1:
	            data = self.request.recv(1024)
	            if len(data) < 1024:
	                total_data.append(data)
	                break
	            total_data.append(data)
        t_data = ''.join(total_data)
        time.sleep(2)
        # reconciliation_res = dummy_comparison(text1, text2)
        self.request.send(nf.find_names(t_data))
				print "nf.find_names(t_data) = %s\n" % nf.find_names(t_data)
        print "Connection %s closed." % conn_name[1]

if __name__ == "__main__":
    HOST, PORT = "localhost", 1234

    # Create the server, binding to localhost on port 1234
    server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)

    print "Initialize server and start listening."
    # Activate the server; this will keep running until you
    # interrupt the program with Ctrl-C
    server.serve_forever()

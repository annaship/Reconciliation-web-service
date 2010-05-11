import SocketServer
import time

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
							# mystery: doesn't work without printing out that
	            # print data
	            if len(data) < 1024:
	                total_data.append(data)
	                break
	            total_data.append(data)
        t_data = ''.join(total_data)
        text1, text2 = t_data.split("&&&EOF&&&")
        # print "text1 = %s, text2 = %s" % (text1, text2)
        # just send back the same data, but upper-cased, for some reason doesn't work properly with "\n", 
        # so need a change "\n"/"\t" and back in Python and Ruby
        time.sleep(2)
        reconciliation_res = text1.replace("\n","\t").upper()
        print "reconciliation_res = %s\n" % reconciliation_res
        self.request.send(reconciliation_res)
        print "Connection %s closed." % conn_name[1]

if __name__ == "__main__":
    HOST, PORT = "localhost", 1234

    # Create the server, binding to localhost on port 1234
    server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)

    print "Server run"
    # Activate the server; this will keep running until you
    # interrupt the program with Ctrl-C
    server.serve_forever()

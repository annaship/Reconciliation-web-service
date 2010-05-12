import SocketServer
import time

class MyTCPHandler(SocketServer.StreamRequestHandler):
	#     """
	#     It is instantiated once per connection to the server, and must
	#     override the handle() method to implement communication to the
	#     client.
	#     """
	
    # def dummy_comparison(first, second):
    #     for a in first:
    #             for b in second:
    #                     if (a && b):
    #                     print "%s ---> %s\n" % a, b
    #                     return "Ura"


    def handle(self):
        # self.request is the TCP socket connected to the client
        total_data = []
        conn = self.request
        conn_name = conn.getpeername()
        def take_set(text):
	            f2 = text.split("\n")
	            f3 = set(f2)
	            return(f3)

        def dummy_comparison(first, second):
	            # definitions = {"guava": "a tropical fruit", "python": "a programming language", "the answer": 42}
	            # matches = {}
	            arr1 = []
	            list_first  = take_set(first)
	            list_second = take_set(second)
	            # print "list_first = %s, " % list_first
	            # print "list_second = %s, " % list_second
	            for a in list_first:
	                # print "a = %s, " % a
	                for b in list_second:
	                    # print "b = %s\n" % b 
	                    arr1.append(a + " ---> " + b)
	                    # if (b == ""):
	                    #     b = "nil"
	                    print "arr1 =%s\n" % arr1
											# sentence = ["there", "is", "no", "spoon"]
											# '+'.join(sentence)
	            res = "\n".join(arr1)
	            return res

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
        # reconciliation_res = text1.replace("\n","\t").upper()
        reconciliation_res = dummy_comparison(text1, text2)
        print "reconciliation_res = %s\n" % reconciliation_res
        self.request.send(reconciliation_res)
        print "Connection %s closed." % conn_name[1]

if __name__ == "__main__":
    HOST, PORT = "localhost", 1234

    # Create the server, binding to localhost on port 1234
    server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)

    print "Server running"
    # Activate the server; this will keep running until you
    # interrupt the program with Ctrl-C
    server.serve_forever()

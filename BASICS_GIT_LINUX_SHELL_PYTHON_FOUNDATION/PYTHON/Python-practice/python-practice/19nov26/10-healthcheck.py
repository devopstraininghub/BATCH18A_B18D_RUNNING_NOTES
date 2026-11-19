

import os 
import sys


def ping_healthcheck(server):
    
    response = os.system(f"ping -n 1 {server}")
    if response == 0:
        print("Healthcheck is success: server is reachable.")
    else:
        print("Healthcheck failed: server is not reachable.")


server = sys.argv[1]

#server = input("Enter the server name or IP address to ping: ")
ping_healthcheck(server)
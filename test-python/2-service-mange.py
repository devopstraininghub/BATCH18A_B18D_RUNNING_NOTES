
import os
import sys

# Function to start a service
def start_service(service_name):
    os.system(f"sudo systemctl start {service_name}")
    print(f"Service {service_name} started")

# Function to stop a service
def stop_service(service_name):
    os.system(f"sudo systemctl stop {service_name}")
    print(f"Service {service_name} stopped")

# Function to display status of a service
def status_service(service_name):
    os.system(f"sudo systemctl status {service_name}")
    print(f"Service {service_name} status")

# Service to manage
service_name = "jenkins"
# service_name = input("Enter service name: ")
# service_name = sys.argv[1]

# Start and stop the service

start_service(service_name)
status_service(service_name)
stop_service(service_name)

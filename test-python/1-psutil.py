import psutil

cpu_usage = psutil.cpu_percent(interval=1)
print(f"CPU Usage: {cpu_usage}%")

memory_info = psutil.virtual_memory()
print(f"Memory information: {memory_info}")

memory_percent = psutil.virtual_memory().percent
print(f"Memory Usage percentage: {memory_percent}%")

disk_usage = psutil.disk_usage('/')
print(f"Disk Usage: {disk_usage.percent}%")
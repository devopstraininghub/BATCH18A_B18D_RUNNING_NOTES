import shutil

monitor_dir = r"C:"

# Disk usage threshold (in percentage)
threshold = 80

# Get disk usage
total, used, free = shutil.disk_usage(monitor_dir)  # returns a tuple of three values

print(total, used, free)  # total, used, and free bytes on the disk

usage_percent = used / total * 100

if usage_percent > threshold:
    print(f"Warning: Disk usage is {usage_percent:.2f}%")
else:
    print(f"Disk usage is {usage_percent:.2f}%, within the threshold")
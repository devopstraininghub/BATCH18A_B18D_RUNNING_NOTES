import shutil

def get_disk_usage(path):
    total, used, free = shutil.disk_usage(path)
    return total, used, free


if __name__ == "__main__":
    path = "/"
    total, used, free = get_disk_usage(path)
    print(f"Total: {total}, Used: {used}, Free: {free}")

    usage_percent = (used / total) * 100
    print(f"Disk usage percentage: {usage_percent:.2f}%")

    if usage_percent > 80:
        print("Warning: Disk usage is above 80%!")
    else:
        print("Disk usage is within acceptable limits.")
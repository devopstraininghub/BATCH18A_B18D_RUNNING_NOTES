import shutil
import os

try:
# Directory to backup
    source_dir = r"C:\Users\Madhukiran\Desktop\batch18keysss"

    # Backup destination
    backup_dir = r"C:\Users\Madhukiran\Desktop\batch18keys_backup"

    # Ensure backup directory exists
    os.makedirs(backup_dir, exist_ok=True)

    # Copy the directory
    shutil.copytree(source_dir, os.path.join(backup_dir, os.path.basename(source_dir)))
    print("Backup completed successfully")


except Exception as e:
    print(f"An error occurred: {e}")


import os
import shutil

def backup_directory(source_dir, backup_dir):
    try:
        shutil.copytree(source_dir, backup_dir)
        print(f"Backup of '{source_dir}' created at '{backup_dir}'")
        
    except Exception as e:
        print(f"Error during backup: {e}")


if __name__ == "__main__":



    source_directory = r"C:\Users\Madhukiran\Desktop\k8s"
    backup_directory_path = r"C:\Users\Madhukiran\Desktop\k8s_backupfiles"


    backup_directory(source_directory, backup_directory_path)
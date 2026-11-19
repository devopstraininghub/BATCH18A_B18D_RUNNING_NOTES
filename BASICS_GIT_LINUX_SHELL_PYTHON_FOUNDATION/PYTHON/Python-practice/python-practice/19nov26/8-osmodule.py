

import os

os.system("ls")            # run a shell command
username = os.getenv("USERNAME")      # read an environment variable

print(f"Current user: {username}")

os.makedirs("mc_folder")  # create a directory (including parents)

print("Directory 'mc_folder' created.")

os.rmdir("mc_folder")      # remove a directory
print("Directory 'mc_folder' removed.")
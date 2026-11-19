

try:
    with open("testfile", "r") as file:
        content = file.read()
        print(content)

except FileNotFoundError:
    print("File not found error occurred. Please check the file name and try again.")

except PermissionError:
    print("Permission error occurred. You do not have permission to access this file.")

except IOError:
    print("An I/O error occurred while trying to read the file.")

except Exception as e:
    print(f"An unexpected error occurred: {e}")



import sys
import os

# print("Python version:", sys.version)
# print("Platform:", sys.platform)    

if len(sys.argv) < 3:
    print("Warning: no proper arguments provided.")
    print("Usage: py script.py <num1> <num2>")
    sys.exit(1)

num1 = sys.argv[1]
num2 = sys.argv[2]

print(f"Sum of {num1} and {num2} is: {int(num1) + int(num2)}")

import sys

def add(a, b):
    output = a + b
    print(f"Addition of {a} and {b} is {output}")


# num1 = int(input("Enter first number: "))
# num2 = int(input("Enter second number: "))

# num1 = 10
# num2 = 20

num1 = int(sys.argv[1])
num2 = int(sys.argv[2])

print(f"Script name is {sys.argv[0]}")

print(f"First number is {num1}")
print(f"Second number is {num2}")

sum = add(num1, num2)

def sum_numbers(num1, num2):

    sum= num1 + num2
    
    return sum



num1 = float(input("Enter first number: "))
num2 = float(input("Enter second number: "))

output = sum_numbers(num1, num2)
print(f"The sum of {num1} and {num2}: {output}")
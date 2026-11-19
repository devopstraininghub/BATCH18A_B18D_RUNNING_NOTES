

# local and global variables
x = 10
y = 20

def add_numbers():
    x = 15
    y = 25
    print(f"Sum of 2 numbers is:, {x + y}")


def multiply_numbers():
    global x
    x = 5
    y = 4
    print(f"Product of 2 numbers is:, {x * y}")


add_numbers()  #---> 40 
multiply_numbers()  # ---> 20
print(f"Global Sum of 2 numbers is:, {x + y}") ## --> 30
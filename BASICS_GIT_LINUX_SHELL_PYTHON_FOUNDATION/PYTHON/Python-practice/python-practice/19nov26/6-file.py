

with open("testfile", "r") as file:
    content = file.read()
    print(content)


with open("testfile", "a") as file:
    file.write("Hi , AWS DEVOPS IS SUPER CRAZY\n")



with open("testfile", "r") as file:
    content = file.read()
    print(content)

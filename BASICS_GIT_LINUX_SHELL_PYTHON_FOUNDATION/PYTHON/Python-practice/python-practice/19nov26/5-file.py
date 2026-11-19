

file = open("devops", "r")
content = file.read()
print(content)
file.close()



file = open("devops", "w")
file.write("Hi , AWS DEVOPS IS SUPER CRAZY.. but python is little tricky \n")
file.close()

file = open("devops", "r")
content = file.read()
print(content)
file.close()
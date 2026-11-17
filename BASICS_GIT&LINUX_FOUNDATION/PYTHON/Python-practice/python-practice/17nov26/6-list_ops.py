
my_list = [1, 2, 3, 1, 4, 5]

my_list.append(4)
print("After append:", my_list)


my_list.extend([8, 9, 7])
print("After extend:", my_list)

my_list.insert(0, 10)
print("After insert:", my_list)

my_list.remove(1)
print("After remove:", my_list)

popped_element = my_list.pop()
print("Popped element:", popped_element)
print("After pop:", my_list)

index_of_9 = my_list.index(9)
print("Index of 9:", index_of_9)

count_of_1 = my_list.count(1)
print("Count of 1:", count_of_1)

my_list.sort()
print("After sort:", my_list)

my_list.reverse()
print("After reverse:", my_list)

copied_list = my_list.copy()
print("Copied list:", copied_list)

my_list.clear()
print("After clear:", my_list)

print("Length of list:", len(my_list))
print("Length of copied list:", len(copied_list))
print("Maximum:", max(copied_list))
print("Minimum:", min(copied_list))
print("Sum:", sum(copied_list))

my_tuple = (3, 1, 4, 1, 5, 9, 2, 6, 5)

count_of_1 = my_tuple.count(1)
print("Count of 1:", count_of_1)

index_of_9 = my_tuple.index(9)
print("Index of 9:", index_of_9)

print("Length:", len(my_tuple))
print("Max:", max(my_tuple))
print("Min:", min(my_tuple))
print("Sum:", sum(my_tuple))

sorted_list = sorted(my_tuple)
print("Sorted tuple as list:", sorted_list)

sorted_list.append(4)
print("After append:", sorted_list)

my_tuple.append(4)  # This will raise an AttributeError since tuples are immutable
print("After append:", my_tuple)
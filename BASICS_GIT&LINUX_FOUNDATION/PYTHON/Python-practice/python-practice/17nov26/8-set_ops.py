my_set = {1, 2, 1, 3, 4, 5}

my_set.add(6)
print("After add:", my_set)

my_set.remove(4)
print("After remove:", my_set)

popped = my_set.pop()
print("Popped:", popped)
print("After pop:", my_set)

my_set.clear()
print("After clear:", my_set)

set_a = {1, 2, 3}
set_b = {3, 4, 5}

print("Union:", set_a.union(set_b))
print("Intersection:", set_a.intersection(set_b))
print("Difference:", set_a.difference(set_b))
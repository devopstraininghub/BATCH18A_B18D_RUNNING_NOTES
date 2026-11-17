

my_dict = {
    "name": "Madhu",
    "phone": "7396627149",
    "city": "Hyderabad"
}

print("Name:", my_dict['name'])

phone = my_dict.get('phone')
print("Phone:", phone)

salary = my_dict.get('salary', 'Not Available')
print("Salary:", salary)

my_dict['occupation'] = 'DevOps Engineer'
print("After adding occupation:", my_dict)

popped_value = my_dict.pop('phone')
print("Popped:", popped_value)
print("After pop:", my_dict)

print("Keys:", list(my_dict.keys()))
print("Values:", list(my_dict.values()))
print("Items:", list(my_dict.items()))

my_dict.clear()
print("After clear:", my_dict)

new_dict = {'a': 1, 'b': 2}
copied_dict = new_dict.copy()
print("Copied:", copied_dict)

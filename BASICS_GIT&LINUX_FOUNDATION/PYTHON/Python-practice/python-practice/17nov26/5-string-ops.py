
my_string = "Hello, Welcome to Aws Devops World"

# 1. Length of the string
print(f"Length of the string: {len(my_string)}")

# 2. Convert to uppercase and lowercase
print(f"Uppercase: {my_string.upper()}")
print(f"Lowercase: {my_string.lower()}")

# 3. Count occurrences of a substring
substring = "Welcome"
print(f"Occurrences of '{substring}': {my_string.count(substring)}")

# 4. Check if the string starts or ends with a particular substring
print(f"Starts with 'Hello': {my_string.startswith('Hello')}")
print(f"Ends with 'World': {my_string.endswith('World')}")

# 5. Find the index of a substring (first occurrence)
print(f"Index of 'World': {my_string.find('World')}")

# 6. Replace a substring with another substring
new_string = my_string.replace('Aws', 'Cloud')
print(f"Original string: {my_string}")
print(f"Modified string: {new_string}")

# 7. Split the string into a list based on a delimiter
words = my_string.split()
print(f"Split into words: {words}")

# 8. Check if all characters are alphanumeric
alphanumeric_string = "Python123$@"
print(f"Is Python alphanumeric? {alphanumeric_string.isalnum()}")

# 9. Convert string to title case
title_case_string = "python programming language"
print(f"Title case: {title_case_string.title()}")
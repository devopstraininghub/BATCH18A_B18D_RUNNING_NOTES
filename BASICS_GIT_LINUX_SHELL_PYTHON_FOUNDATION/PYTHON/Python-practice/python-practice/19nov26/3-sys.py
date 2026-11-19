

import sys

env_name = sys.argv[1]
release_name = sys.argv[2]

print(f"Script name is {sys.argv[0]}")

print(f"Environment name is {env_name}")
print(f"Release name is {release_name}")

#########  logic to deploy the release in the environment ############
########   code & logic
######

print(f"Release {release_name} is deployed in {env_name} environment successfully")
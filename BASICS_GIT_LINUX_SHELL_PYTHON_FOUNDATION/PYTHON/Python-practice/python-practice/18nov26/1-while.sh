

#!/bin/bash

# while loop
num=1 
while [ $num -le 100 ]
do
  echo "THE VALUE OF NUMBER IS $num"
  
  num=$((num + 1))

done

echo "Done with printing numbers from 1 to 100"
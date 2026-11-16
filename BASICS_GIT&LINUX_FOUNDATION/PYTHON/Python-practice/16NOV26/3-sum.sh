
#!/bin/bash

sum() {
    num1=$1
    num2=$2
    result=$(( $1 + $2  ))
    echo "The sum of $1 and $2 is: $result"
}

sum 5 10
sum 20 30
sum 7 3




num = 1
while num <= 100:
    print(f"THE VALUE OF NUMBER IS {num}")

    if num == 5:
        print("BREAKING THE LOOP AS NUMBER IS 5")
        break

    num = num + 1


print("Done with printing numbers from 1 to 5 as we have broken the loop when number is 5")
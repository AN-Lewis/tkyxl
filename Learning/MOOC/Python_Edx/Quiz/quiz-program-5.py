def McNuggets(n):
    """
    n is an int

    Returns True if some integer combination of 6, 9 and 20 equals n
    Otherwise returns False.
    """
    # Your Code Here
    max6 = int(n/6)+1
    max9 = int(n/9)+1
    max20 = int(n/20)+1
    
    for i in range(0,max6):
        for j in range(0,max9):
            for z in range(0,max20):
                if 6*i +j*9 +z*20 == n:
                    return (True)
    return (False)

print (McNuggets(15))
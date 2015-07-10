def myLog(x, b):
    '''
    x: a positive integer
    b: a positive integer; b >= 2

    returns: log_b(x), or, the logarithm of x relative to a base b.
    '''
    # Your Code Here
   
    def calpower(b,n):
        if n == 1:
            return (b)
        else:
            return b * calpower(b,n-1)
    
    for i in range(1,x):
        if calpower(b,i)-x == 0:
            return (i)
            break
        elif calpower(b,i)-x > 0:
            return (i-1)
            break

print(myLog(16, 4))
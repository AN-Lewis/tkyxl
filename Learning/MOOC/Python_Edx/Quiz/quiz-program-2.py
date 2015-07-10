def laceStrings(s1, s2):
    """
    s1 and s2 are strings.

    Returns a new str with elements of s1 and s2 interlaced,
    beginning with s1. If strings are not of same length, 
    then the extra elements should appear at the end.
    """
    if len(s1) <= len(s2):
        minsize = len(s1)
        maxsize = len(s2)
    else:
        minsize = len(s2)
        maxsize = len(s1)
    
    outstring =""
    for i in range(0,minsize):
        outstring = outstring + s1[i] + s2[i]
    
    
    if maxsize> minsize:
        if len(s1) <= len(s2):
            outstring = outstring + s2[minsize:maxsize]
        else:
            outstring = outstring + s1[minsize:maxsize]
    return (outstring)

print(laceStrings("abcd","123456789"))
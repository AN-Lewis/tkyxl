import ps6_encryption
import string



orig_lower = string.ascii_lowercase
orig_upper = string.ascii_uppercase

def buildCoder(shift):
    
    orig_lower = string.ascii_lowercase
    orig_upper = string.ascii_uppercase
    orig = orig_lower + orig_upper

    modi_lower = orig_lower[shift:]+orig_lower[:shift]
    modi_upper = orig_upper[shift:]+orig_upper[:shift]
    modi = modi_lower + modi_upper
    
    shift_dict = dict( zip(  list(orig), list(modi)  ) )
    return(shift_dict)
    

def applyCoder(text, coder):
    """
    Applies the coder to the text. Returns the encoded text.

    text: string
    coder: dict with mappings of characters to shifted characters
    returns: text after mapping coder chars to original text
    """
    from string import maketrans
    transtab = maketrans(str(coder.keys()),str(coder.values()))
    return(text.translate(transtab))

def applyShift(text, shift):
    coder = buildCoder(shift)
    return(applyCoder(text,coder))


print(applyShift('This is a test.', 8))  
print(applyShift('Hello, world!', 19))
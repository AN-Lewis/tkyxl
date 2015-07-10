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
    

print(buildCoder(3))
import re
f= open('~/Desktop/CMdiff_RNAseq.txt','r')

data = f.read()
f.close()

def RNAseqParser(data): 
    
    out = ""
    lines = data.split("\n")
    for line in lines: 
        if line.startswith("ensGene"):
            continue
        myPattern = re.search(r"\S+\t(\S+)\t\S+\t\S+\t(\S+)\t.*", line)
        if myPattern:
            out = out + myPattern.group(1)+"\t"+myPattern.group(2)+"\n"       
    return(out)

myresult = RNAseqParser(data)
print myresult
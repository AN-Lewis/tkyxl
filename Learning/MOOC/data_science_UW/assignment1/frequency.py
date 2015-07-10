import sys
import json
import re

def lines(fp):
    print str(len(fp.readlines()))

def main():
    tweet = open(sys.argv[1])

    scores={}
    
    totalword=0
    freqtable={}
        
    for line in tweet:
        data = json.loads(line)
        moodscore = 0

        if 'text' in data:
            words = data.get("text")
            words.encode('utf-8')
            words = words.lower()
            words = words.strip()
            words = re.sub('[.!,;]', '', words)
            words = words.split()

            for word in words:
                totalword += 1
                if freqtable.has_key(word):
                    freqtable[word] +=1
                else:
                    freqtable[word] = 1

    for k,v in freqtable.items():
        print k+" "+ str(float(v)/float(totalword))#
#    print totalword





if __name__ == '__main__':
    main()

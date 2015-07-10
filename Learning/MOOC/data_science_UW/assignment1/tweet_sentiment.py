import sys
import json
import re

def lines(fp):
    print str(len(fp.readlines()))

def main():
    sent = open(sys.argv[1])
    tweet = open(sys.argv[2])

    scores={}

    for line in sent:
        line = line.strip()
        term,score = line.split("\t")
        scores[term] =int(score)

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
                if scores.has_key(word):
                    moodscore = moodscore + scores[word]

        print moodscore





if __name__ == '__main__':
    main()

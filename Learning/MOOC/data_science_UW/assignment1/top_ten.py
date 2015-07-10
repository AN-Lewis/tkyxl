# top_ten.py

import sys
import json
import re


def main():
  
    tweet = open(sys.argv[1])
    
    tags = []
    unique = {}

    
    # Read the tweet file    
    for line in tweet:
        data = json.loads(line)
        
        # Skip non-English tweets
        if not data.get("lang")=="en":
            continue     
        
        if data.get("entities") is None:
            continue    
        
        if data["entities"]["hashtags"] != []:
            for tag in data["entities"]["hashtags"]:
        	    if tag["text"].isalnum():
        		    tags.append((tag["text"]))
                    
            
    for tg in tags:
        if unique.has_key(tg):
            unique[tg] += 1
        else:
            unique[tg] = 1
   
    line = 1
    print "############################################"
    for w in sorted(unique, key=unique.get, reverse=True):
      print w, unique[w]
      line +=1
      if line > 10:
          break    
        
if __name__ == '__main__':
    main()

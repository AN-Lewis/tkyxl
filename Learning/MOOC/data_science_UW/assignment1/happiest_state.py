import sys
import json
import re

states = {
        'AK': 'Alaska',
        'AL': 'Alabama',
        'AR': 'Arkansas',
        'AS': 'American Samoa',
        'AZ': 'Arizona',
        'CA': 'California',
        'CO': 'Colorado',
        'CT': 'Connecticut',
        'DC': 'District of Columbia',
        'DE': 'Delaware',
        'FL': 'Florida',
        'GA': 'Georgia',
        'GU': 'Guam',
        'HI': 'Hawaii',
        'IA': 'Iowa',
        'ID': 'Idaho',
        'IL': 'Illinois',
        'IN': 'Indiana',
        'KS': 'Kansas',
        'KY': 'Kentucky',
        'LA': 'Louisiana',
        'MA': 'Massachusetts',
        'MD': 'Maryland',
        'ME': 'Maine',
        'MI': 'Michigan',
        'MN': 'Minnesota',
        'MO': 'Missouri',
        'MP': 'Northern Mariana Islands',
        'MS': 'Mississippi',
        'MT': 'Montana',
        'NA': 'National',
        'NC': 'North Carolina',
        'ND': 'North Dakota',
        'NE': 'Nebraska',
        'NH': 'New Hampshire',
        'NJ': 'New Jersey',
        'NM': 'New Mexico',
        'NV': 'Nevada',
        'NY': 'New York',
        'OH': 'Ohio',
        'OK': 'Oklahoma',
        'OR': 'Oregon',
        'PA': 'Pennsylvania',
        'PR': 'Puerto Rico',
        'RI': 'Rhode Island',
        'SC': 'South Carolina',
        'SD': 'South Dakota',
        'TN': 'Tennessee',
        'TX': 'Texas',
        'UT': 'Utah',
        'VA': 'Virginia',
        'VI': 'Virgin Islands',
        'VT': 'Vermont',
        'WA': 'Washington',
        'WI': 'Wisconsin',
        'WV': 'West Virginia',
        'WY': 'Wyoming'
}


def main():
    sent = open(sys.argv[1])
    tweet = open(sys.argv[2])

    scores={}
    sentimatrix ={}
    statemood={}
    
    # Extract the sentimental score and store in hash
    for line in sent:
        line = line.strip()
        term,score = line.split("\t")
        scores[term] =int(score)
     
    
    # Read the tweet file    
    for line in tweet:
        data = json.loads(line)
        moodscore = 0
        
        # Skip non-English tweets
        if not data.get("lang")=="en":
           continue
        
        # Skip if there is no "place" information       
        if data.get("place") is None:
            continue
            
        # Skip if not US 
        if not data.get("place")["country_code"] == "US":
            continue
     
            
        # Calculate moodscore
        if 'text' in data:
            words = data.get("text")
            words.encode('utf-8')
            words = words.lower()
            words = words.strip()
            words = re.sub('[.!,;-_#]', '', words)
            words = words.split()
            for word in words:
                if scores.has_key(word):
                    moodscore = moodscore + scores[word]
        
        # get tweet location and extract state information 
        tweetloc = data.get("place")["full_name"]
        tweetloc = re.sub('\s', '', tweetloc)
        city,state = tweetloc.split(",")
        if states.has_key(state):
            if statemood.has_key(state):
                statemood[state] = statemood[state]+ moodscore
            else:
                statemood[state] = moodscore
        


    happiest_state = statemood.keys()[0]
    for state in statemood:
        if statemood[state] > statemood[happiest_state]:
            happiest_state = state
    print happiest_state

if __name__ == '__main__':
    main()

import oauth2 as oauth
import urllib2 as urllib
import json
# See assignment1.html instructions or README for how to get these credentials

api_key = "OvsbFrMD0mfNVA6EVGDnZX2PT"
api_secret = "G4SP3CJ9v516WfEzBXpQLUUHXl1puF3ychLFsq0EA6x0Yzx1eb"
access_token_key = "2607330859-OEG4eyPRBrTCNMifPvt3QZqkrZ622Tj2yebeLgP"
access_token_secret = "kee6VITk2k4LgTdFsnrykjn2FjsvevgXU0V5oUxRPqx4V"

_debug = 0

oauth_token    = oauth.Token(key=access_token_key, secret=access_token_secret)
oauth_consumer = oauth.Consumer(key=api_key, secret=api_secret)

signature_method_hmac_sha1 = oauth.SignatureMethod_HMAC_SHA1()

http_method = "GET"


http_handler  = urllib.HTTPHandler(debuglevel=_debug)
https_handler = urllib.HTTPSHandler(debuglevel=_debug)

'''
Construct, sign, and open a twitter request
using the hard-coded credentials above.
'''
def twitterreq(url, method, parameters):
  req = oauth.Request.from_consumer_and_token(oauth_consumer,
                                             token=oauth_token,
                                             http_method=http_method,
                                             http_url=url, 
                                             parameters=parameters)

  req.sign_request(signature_method_hmac_sha1, oauth_consumer, oauth_token)

  headers = req.to_header()

  if http_method == "POST":
    encoded_post_data = req.to_postdata()
  else:
    encoded_post_data = None
    url = req.to_url()

  opener = urllib.OpenerDirector()
  opener.add_handler(http_handler)
  opener.add_handler(https_handler)

  response = opener.open(url, encoded_post_data)

  return response

tags = []
unique = {}
def fetchsamples():
  url = "https://stream.twitter.com/1/statuses/sample.json"
  parameters = []
  response = twitterreq(url, "GET", parameters)
  number = 1
  linenumber = 1 
  for line in response:
        data = json.loads(line)
        print linenumber
        linenumber +=1
        # Skip non-English tweets
        if not data.get("lang")=="en":
            continue     
        
        if data.get("entities") is None:
            continue    
        
        if data["entities"]["hashtags"] != []:
            for tag in data["entities"]["hashtags"]:
        	    if tag["text"].isalnum():
        		    tags.append((tag["text"].lower()))
                    number = number +1
                    print "hash exist: " + str(number)
        if number >3500:
            break         
            
    
    

if __name__ == '__main__':
  fetchsamples()
  
  for tg in tags:
      if unique.has_key(tg):
          unique[tg] += 1
      else:
          unique[tg] = 1
 
  line = 1
  print "################################################"
  for w in sorted(unique, key=unique.get, reverse=True):
    print w, unique[w]
    line +=1
    if line > 30:
        break

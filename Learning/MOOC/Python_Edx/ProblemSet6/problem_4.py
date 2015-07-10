import ps6_encryption

def findBestShift(wordList, text):
    """
    Finds a shift key that can decrypt the encoded text.

    text: string
    returns: 0 <= int < 26
    """
    best_fit = 0
    best_score = 0
    
    for k in range(1,26):
        score = 0
        possible_text = applyShift(text, k)
        for word in possible_text.split(" "):
            if isWord(wordList, word):
                score = score + 1
        if score > best_score:
            best_score = score
            best_fit = k 
    
    return(k)

s = applyShift('Hello, world!', 8)
print(findBestShift(wordList, s))
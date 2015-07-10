### SyntenyMapping

A script used to define human-to-mouse synteny region.  
This script is based on [Ensembl Perl API](http://www.ensembl.org/info/docs/api/index.html) (Comparative genomics)   

##### How it works
A two-step mapping strategy is used to define the synteny region:   
1. Fetch the large synteny block for the given region   
2. Perform clustalw comparision for input sequences and take the maximum-length fragment as the final syntenic region   

##### System Requirement:
1. Linux or Mac OS system (head, tail and sort are used)  
2. Ensemble Perl API  

##### Input and Output
Input   file  : a Bed format like file with genetic loci in human genome (hg19).   
Output  file  : Corresponding synteny region in mouse genome (mm10)   


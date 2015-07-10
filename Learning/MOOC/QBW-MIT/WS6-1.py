from qbwPythonModule import *

gene_file='mm9_sel_chroms_knownGene.txt'
gene_info=loadGeneFile(gene_file)

fa_file='selChroms_mm9.fa.zip'
seq_dict=loadFasta(fa_file)

len(seq_dict)
seq_dict.keys()

'''CNTN4 INFO'''

cntn4="uc009dcr.2"
gene_info[cntn4]
gene_info[cntn4]['chr']
len(seq_dict['chr6'])


# A NEW DICTIONARY OF DATA
# Using the len function, how long is chromosome 6?  
print len(seq_dict['chr6'])

# Using the len function, how long is chromosome 6?  
print len(seq_dict['chr16'])
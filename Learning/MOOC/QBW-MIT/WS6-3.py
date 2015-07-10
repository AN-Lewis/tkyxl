from qbwPythonModule import *

fa_file='selChroms_mm9.fa.zip'
seq_dict=loadFasta(fa_file)

gene_file='mm9_sel_chroms_knownGene.txt'
gene_info=loadGeneFile(gene_file)

in_gene=set()

for gene in gene_info.keys():
    if gene_info[gene]['chr']=='chr6':
        gene_inds=range(gene_info[gene]['start'],gene_info[gene]['end'])
        in_gene.update(gene_inds)


tata_dist={}

for g in chr6_starts.keys():
    e=chr6_starts[g]
    strand=gene_info[g]['strand']
    if strand=='+':
      s=e-40
    else:
      s=e
      e=s+40
    if 'TATA' in seq_dict['chr6'][s:e].upper():
      if strand=='+':
        tata_dist[g]=seq_dict['chr6'][s:e].upper().rindex('TATA')
      else:
        tata_dist[g]=seq_dict['chr6'][s:e].upper().index('TATA') 
        
np.mean(tata_dist.values())

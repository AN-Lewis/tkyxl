FPRP <- alpha*(1-p)/(= α (1 – π)/(α(1 – π) + (1 – β) π)

where pi is the prior probability of a true association of the tested genetic variant with a disease, 
(1 – beta) is the statistical power and 
alpha is the significance level or observed P value. 
We estimated the FPRP to be 0.5 and (1 – beta) to be at least 0.8. 
We set the prior probability (pi) to 20/249,133 for genome-wide SNPs; 
if FPRP = 0.5 
then 
α(1 – p) = (1 – β) p

alpha <-  ((1-beta)*p)/(1-p)
p <- 20/249133
beta <- 0.2
alpha
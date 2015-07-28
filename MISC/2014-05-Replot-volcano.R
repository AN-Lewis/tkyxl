library("limma")
setwd("D:/Dropbox/Agilent-Early-stage/")
dir()
targets <- readTargets("targets.txt")
targets
t <- read.maimages(targets, path="./", source="agilent",green.only=TRUE)
y <- backgroundCorrect(t, method="normexp", offset=16)
y <- normalizeBetweenArrays(y, method="quantile")
y
y.ave <- avereps(y, ID=y$genes$ProbeName)
f <- factor(targets$Condition, levels = unique(targets$Condition))
design <- model.matrix(~0 + f)
design
colnames(design) <- levels(f)
fit <- lmFit(y.ave, design)
contrast.matrix <- makeContrasts("AS-WT", levels=design)
fit2 <- contrasts.fit(fit, contrast.matrix)
fit2 <- eBayes(fit2)
output <- topTable(fit2, adjust="BH", coef="AS-WT", genelist=y.ave$genes, number=Inf)
write.table(output, file="AS_vs_WT_quote.txt", sep="\t", quote=TRUE)
write.table(y.ave,file="Probe-level-expression-data",sep="\t",quote=FALSE)
write.table(y$out,file="Probe-level-expression-data-with-cBind",sep="\t",quote=FALSE)

y$oyt <- cbind(y$genes, y$E)####
write.table(y$out,file="true-Probe-level-expression-data",sep="\t",quote=FALSE)
y$out <- cbind(y$genes, y$E)####
y$M
x <- read.table("Pat_vs_WT_early_stage.txt",header=T,sep="\t",quote="\"")
x <- read.table("only1",header=T,sep="\t",quote="\"")
plot(x$logFC,-log10(x$P.Value),pch=20,xlim=c(-2,2),ylim=c(0,5.5),col=rgb(0, 0, 0, alpha=0.5),,xlab="log(FC)",ylab="-log10(P)")
points(x[x$GeneName=="Sfrp4", 11], -log10(x[x$GeneName=="Sfrp4", 14]), col="black",pch=17,cex=.9)
points(x[x$GeneName=="Sfrp5", 11], -log10(x[x$GeneName=="Sfrp5", 14]), col="black",pch=17,cex=.9)
abline(h=-log10(0.01),col="red",lty="44")
abline(v=log2(1.5),col="red",lty="44")
abline(v=log2(1/1.5),col="red",lty="44")
identify(x=x$logFC, -log10(x$P.Value), label=x$GeneName,cex=0.7)
library(affy)

x[x$logFC>log2(1.5) & x$P.Value<= 0.01, ]$GeneName
x[x$logFC<log2(1/1.2) & x$P.Value<= 0.01, ]$GeneName
write.table(x[x$logFC<log2(1/1.2) & x$P.Value<= 0.01, ],file="downregulated-1.2fold-0.01.txt", sep="\t", quote=TRUE)
write.table(x[x$logFC>log2(1/1.2) & x$P.Value<= 0.01, ],file="upregulated-1.2fold-0.01.txt", sep="\t", quote=TRUE)
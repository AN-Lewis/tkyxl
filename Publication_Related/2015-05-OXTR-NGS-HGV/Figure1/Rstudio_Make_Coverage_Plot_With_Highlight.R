rm(list=ls())
library(Gviz)
library(GenomicRanges)
library(GenomicFeatures)
require(xlsx)

setwd("~/Desktop/Coverage_Plot_V4/")

####################################
chr <- 3
gen <- "hg19"

from <- 8790600 
to <- 8811731 

from_plus <- 8790600 - 200
to_plus <- 8811731 + 200
####################################

txdb <- loadDb("~/hg19_knowngene.sqlite")
txTr <- GeneRegionTrack(txdb, chromosome = "chr3",start = from_plus, end = to_plus, symbol = T, name = "Gene",background.title = "darkblue")

itrack <- IdeogramTrack(genome=gen, chromosome=chr)
gtrack <- GenomeAxisTrack()

####################################

Miseq_count <-  read.table("Input/Miseq_coverage_per_bp.txt", header=F,stringsAsFactors = F)


Miseq_cov <- GRanges(seqnames = Rle(Miseq_count$V1), ranges = IRanges(start = Miseq_count$V2 + Miseq_count$V5, end = Miseq_count$V2 + Miseq_count$V5), coverage=Miseq_count$V6 )



####################################

gcContent <- UcscTrack(genome=gen, chromosome="chr3", track="GC Percent", table="gc5Base",
                                               from=from_plus, to=to_plus, trackType="DataTrack", start="start", end="end", data="score",
                                               type="hist", window=-1, windowSize=50, fill.histogram="Gainsboro", col.histogram="Gainsboro",
                                               ylim=c(40, 90), name="GC Percent",fill="#800000")

availableDisplayPars(gcContent)
plotTracks(gcContent)

####################################

Novel_Miseq <- read.xlsx("Input/novel_Miseq.xlsx",1, as.is=T)
All_Miseq <- read.xlsx("Input/Miseq_all.xlsx",1,as.is=T)

Novel_SNPs_Miseq <- GRanges(seqnames = Rle(Novel_Miseq$Chr), ranges = IRanges(start = Novel_Miseq$Start, end = Novel_Miseq$End))

All_Miseq <- GRanges(seqnames =Rle(All_Miseq$Chr), ranges = IRanges(start = All_Miseq$Start, end = All_Miseq$Start))

ht <- HighlightTrack(trackList = list(txTr,Mi_Track,gcContent,Misnp_Track), start = c(8808952),end=c(8810050), chromosome = 3)

displayPars(Misnp_Track)


plotTracks(aTrack)

depth.color ="darkblue"
gc.color="Maroon"
dhs.color ="Steel Blue"
all.color="Steel Blue"


Mi_Track <- DataTrack(Miseq_cov, name = "Depth", type="h", col="Slate Gray 3",background.title = depth.color,cex.title=T)
displayPars(gcContent) <- list(background.title = gc.color,cex.title=T,fill.histogram="Sea Shell 3", col.histogram="Sea Shell 3")
aTrack <- AnnotationTrack(start = c(8797241, 8798406, 8799886,8801161,8809146,8810366), end = c(8797650,8798675,8800275,8801495,8810355,8811430), chromosome = "chr3", strand = c("*","*", "*","*","*","*"), genome = "hg19", name = "DHS",background.title = dhs.color ,cex.title=F,fill="coral1")
Misnp_Track_all <-  GeneRegionTrack(All_Miseq, chromosome = "chr3",start = from_plus, end = to_plus, symbol = T, name = "All variations",background.title = all.color,cex.title=T,fill="orange",col="orange")
Misnp_Track <- GeneRegionTrack(Novel_SNPs_Miseq, chromosome = "chr3",start = from_plus, end = to_plus, symbol = T, name = "Novel Mutations",background.title = all.color,cex.title=T,fill="khaki",col="gray14")

plotTracks(list(itrack,gtrack, txTr,Mi_Track,gcContent,aTrack,Misnp_Track_all,Misnp_Track))


"darkblue"
"lightskyblue3"
"darkslateblue"
"Steel Blue"


save.image(file="Coverage_Plot_All.Rdata")

tiff( "mygraph.tiff")
plotTracks(list(itrack,gtrack,ht))
plotTracks(list(itrack,gtrack, txTr,Mi_Track,gcContent,aTrack,Misnp_Track_all,Misnp_Track))
dev.off()

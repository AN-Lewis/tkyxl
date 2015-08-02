#arrayCGH analyis and plotting 
#2015-03-15 version 1
#Package requrired: DNAcopy Gviz GenomicRanges 


rm(list=ls())

library("DNAcopy")
library("Gviz")
library("GenomicRanges")


#set the working directory where the raw data saved
setwd("~/Desktop/aCGH/Data2/")


# conver_rawdata
# a function to extract raw logRation data and chromosome position to a df 
convert_rawdata <- function (raw_file){
  temp.file <- read.table(file = raw_file, skip = 9 , header=T, stringsAsFactors =FALSE)
  usable <- grep("chr",temp.file$SystematicName)
  temp.pos = as.vector(sapply(strsplit(as.character(temp.file[usable,]$SystematicName),":"), "[", 2))
  final.pos = sapply(strsplit(temp.pos,"-"),"[",1)
  temp.chr = as.vector(sapply(strsplit(as.character(temp.file[usable,]$SystematicName),":"), "[", 1))
  final.chr <- gsub("chr", "", temp.chr)
  obj_df <- data.frame(logR=temp.file[usable,]$LogRatio,
                       Chr=final.chr,
                       Pos=as.numeric(final.pos)/1000
  )
  return(obj_df)
}

# It will take quite a while for this step
data_dup_1.4 <- convert_rawdata("Cy5_1.4Mb_pat_tail_vs_Cy3_WT.txt")
data_dup_3 <- convert_rawdata("Cy5_3Mb_pat_tail_vs_Cy3_WT.txt")
data_dup_6 <- convert_rawdata("Cy5_6Mb_pat_tail_vs_Cy3_WT.txt")



# prepare for the CNA object
CNA.object <- CNA(cbind(data_dup_1.4$logR,
                        data_dup_3$logR,
                        data_dup_6$logR),
                  data_dup_1.4$Chr, # Not Numeric
                  as.numeric(data_dup_1.4$Pos),
                  data.type="logratio",
                  sampleid=c("dup1.4","dup3","dup6")
)


# Run smoothing 
smotthed.CNA.object <- smooth.CNA(CNA.object)

# Run segmentation analysis
segment.smoothed.CNA.object <- segment(smotthed.CNA.object, verbose = 1)


# Check the initial plot
plot(segment.smoothed.CNA.object,plot.type="s")
zoomIntoRegion(segment.smoothed.CNA.object,7,sampleid="dup1.4",maploc.start=65000,maploc.end=70000)
zoomIntoRegion(segment.smoothed.CNA.object,7,sampleid="dup3",maploc.start=65000,maploc.end=70000)
zoomIntoRegion(segment.smoothed.CNA.object,7,sampleid="dup6",maploc.start=61000,maploc.end=71000)


# Save the output data 
segments <- segment.smoothed.CNA.object$output
signal_data <- as.data.frame(segment.smoothed.CNA.object$data)

# reset the positions
colnames(segments)
segments$loc.start = segments$loc.start*1000
segments$loc.end = segments$loc.end*1000
signal_data$maploc = signal_data$maploc*1000

# Log10 -> Log2 convertion 
signal_data[,c(3,4,5)] <- log2(10)*signal_data[,c(3,4,5)]
segments$seg.mean <-  log2(10)*segments$seg.mean

# Save the segmentation file
write.csv(segments, file="segmentation.csv")

# Prepare the plots
# Set the target regions
chr <- "chr7"
genome <- "mm9"
from =62000000
to = 71000000

# Make ideograph and gTrack
itrack <- IdeogramTrack(genome=genome, chromosome=chr)
gtrack <- GenomeAxisTrack()

# Download UCSC RefSeqGene Track
# It will take a while
refseqGene <- UcscTrack(genome = genome, chromosome = chr,
                        track = "refGene", from = from, to = to, trackType = "GeneRegionTrack",
                        rstarts = "exonStarts", rends = "exonEnds", gene = "name",
                        symbol = "name2", transcript = "name", strand = "strand",
                        fill = "#D28282", name = "refGenes", cex.title = 1.2, background.title = "darkblue",fontsize = 20,fontcolor.group="black",
                        showId = TRUE, collapseTranscripts=FALSE,cex.title=0.8, lwd=2,arrowHeadWidth=20)

#just a memo how to reset parameters
displayPars(refseqGene) <- list(fontsize = 20,fontcolor.group="black",fontcolor="red",
                                col = NULL, collapseTranscripts=FALSE,cex.title=0.8,fill="#D28282",background.title="darkblue",showId=TRUE,lwd=2,arrowHeadWidth=20)



#Extract signal of target regions  
targetsignal <- subset(signal_data,chrom == 7 & maploc > 62000000 & maploc <71000000)

write.table(targetsignal,file = "target_signal.csv",quote = TRUE, sep = ",",row.names = FALSE)
rm(targetsignal)
#Manually manipulate the data to add extra columns 


targetsignal<-read.csv(file="target_signal.csv",header=T)

#Prepare the Geange objects
dup1.4 <-GRanges(seqnames = Rle("Chr7"), ranges = IRanges(start = targetsignal$maploc, end = targetsignal$maploc), signal=targetsignal$dup1.4,signalmean=targetsignal$dup1.4mean)
dup3 <- GRanges(seqnames = Rle("Chr7"), ranges = IRanges(start = targetsignal$maploc, end = targetsignal$maploc), signal=targetsignal$dup3,signalmean=targetsignal$dup3mean )
dup6 <- GRanges(seqnames = Rle("Chr7"), ranges = IRanges(start = targetsignal$maploc, end = targetsignal$maploc), signal=targetsignal$dup6,signalmean=targetsignal$dup6mean)

d1.4Track <- DataTrack(dup1.4, groups = rep(c("dup1.4", "dup1.4mean"),each=1),name = "1.4 mb dup", type=c("p","p"),col=c("black","red"),fontsize = 20,background.title="Maroon")
d3Track <- DataTrack(dup3, groups = rep(c("dup3", "dup3mean"),each=1), name = "3 mb dup", type=c("p","p"),col=c("black","red"),fontsize = 20,background.title="Maroon")
d6Track <- DataTrack(dup6, groups = rep(c("dup6", "dup6mean"),each=1),name = "6 mb dup", type=c("p","p"),col=c("black","red"),fontsize = 20,background.title="Maroon")


tiff( "dup3and6.tiff",width = 1300,height = 800)
plotTracks(c(itrack,gtrack,d3Track,d6Track,refseqGene),showId = TRUE, from = from , to=to)
dev.off()

tiff( "dup1.4_3_6.tiff",width = 1300,height = 800)
plotTracks(c(itrack,gtrack,d1.4Track,d3Track,d6Track,refseqGene),showId = TRUE, from = from , to=to)
dev.off()


# Highlight if neccessary
hl2 <- HighlightTrack(trackList = list(d3Track,refseqGene), start = c(66257111, 69305187), width = 7000, chromosome = 7)


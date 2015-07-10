
rm(list=ls())
setwd("~/Desktop/Coverage_Plot_V4/")
load("Coverage_Plot_All.Rdata")
library(Gviz)

tiff( "Output/Coverage-plot-with-highlight.tiff", width=3000, height=1800,res=300)
plotTracks(list(itrack,gtrack, txTr,Mi_Track,gcContent,aTrack,Misnp_Track_all,Misnp_Track))
dev.off()


data <- read.table(file="~/Desktop/autism.count.txt", header =F, as.is=T)
data
colnames(data) <- c("Year","publication Number")
barplot(data[,1], xlab = "Year", ylab = "Publication Number")
library(ggplot2)
theme_set(theme_grey(base_size = 20))
qplot(x=data[,1], y=data[,2], geom="bar", stat="identity",xlab = "Year",xlim=c(2000,2015),
      ylab="Publication Number", fill = I("indianred1") ) + theme(axis.title.x = element_text(face="bold", colour="black", size=20),
      axis.title.y  = element_text(face="bold", colour="black", size=20))

qplot()
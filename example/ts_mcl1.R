rm(list = ls())

library(ggrepel)
library(ggplot2)
library(xlsx)
library(zeptosensUtils)
library(zeptosensPkg)
##########
#Functions
##########
get_volcano_plot <- function(ts, q_value,
                             filename,
                             path = getwd(),
                             sig_value = 0.4,
                             include_labels = TRUE,
                             save_output = TRUE) {
  ts <- as.matrix(ts)
  p_adj <- as.matrix(q_value)
  
  if (nrow(p_adj) != nrow(ts)) {
    stop("ERROR: Tag of ts and q_value does not match.")
  }
  
  tmp_dat <- data.frame(cbind(ts, -1 * log10(p_adj)))
  colnames(tmp_dat) <- c("ts", "neglogQ")
  
  color <- ifelse(p_adj > sig_value, "not significant", "significant")
  rownames(color) <- rownames(ts)
  tmp_dat$labelnames <- row.names(tmp_dat)
  sig01 <- subset(tmp_dat, tmp_dat$neglogQ > -1 * log10(sig_value))
  siglabel <- sig01$labelnames
  tmp_dat$color <- color
  
  p <- ggplot() +
    geom_point(data = tmp_dat, aes(x = ts, y = neglogQ, color = color), alpha = 0.4, size = 2) +
    xlab("<ts>") + ylab("-log10 (Q-Value)") + ggtitle("") +
    scale_color_manual(name = "", values = c("black", "red")) +
    theme_bw()
  
  if (include_labels) {
    p <- p + geom_label_repel(data = sig01, aes(x = sig01$ts, y = sig01$neglogQ, label = siglabel), size = 5)
  }
  
  if (save_output) {
    plotname <- file.path(path, paste0(filename, ".pdf"))
    ggplot2::ggsave(plotname, p)
    tmp_dat_f <- cbind(tmp_dat$ts, tmp_dat$neglogQ)
    colnames(tmp_dat_f) <- c("ts", "neglogQ")
    csvname <- file.path(path, paste0(filename, ".csv"))
    write.csv(tmp_dat_f, file = csvname)
  }
  
  return(p)
}


######
nDose=1
nProt=217
maxDist=1 # changing this value requires additional work to compute product(wk). This is not a priority

#read proteomic response for stdev calculation
inputFile <- file.path("example/example_hcc1954.csv")
x_A <- read.table(inputFile)

stdev <- sampSdev(nSample=16,nProt=nProt,nDose=nDose,nX=x_A)
networks <- network(nProt=nProt,
                    proteomicResponses=x_A,
                    maxDist=maxDist)

wk <- networks$wk
wks <- networks$wks
dist_ind <- networks$dist_ind
inter <- networks$inter

#TS
cell_line <- rownames(x_A)


targetScoreOutputFile <-paste0("HCC1954","_TS.txt")
matrixWkOutputFile <- "wk_1.txt"
signedMatrixWkOutputFile <- "wks.txt"
nPerm=1000
nCond=16
nDose=1
maxDist <- 1

proteomicResponses_1 <- x_A
for(i in 1:nProt){
  for (j in 1:nCond){
    proteomicResponses_1[j,i] <- (x_A[j,i]/stdev[i])
  }
}
write.table(proteomicResponses_1,file=paste0("HCC1954","_Zresp.txt"),quote=F)
nrow(proteomicResponses_1)

TS<-array(0,dim=c(nCond,nProt))
TS_q<-array(0,dim=c(nCond,nProt))

for (i in seq_len(nCond)){
  results <- getTargetScore(wk=wk,
                            wks=wks,
                            dist_ind=dist_ind,
                            inter=inter,
                            nDose=nDose,
                            nProt=nProt,
                            proteomicResponses=proteomicResponses_1[i,],
                            maxDist=maxDist,
                            nPerm=nPerm,
                            cellLine=cell_line[i],
                            targetScoreOutputFile=targetScoreOutputFile,
                            matrixWkOutputFile=matrixWkOutputFile,
                            targetScoreQValueFile=paste0(cell_line[i],"_q.txt"),
                            targetScoreDoseFile=paste0(cell_line[i],"_TS_d.txt"),
                            targetScorePValueFile=paste0(cell_line[i],"_p.txt"),
                            verbose=FALSE,fsFile="example/fs.txt",
                            signedMatrixWkOutputFile=signedMatrixWkOutputFile)
  TS[i,]<-results$ts
  TS_q[i,]<-results$q
}


colnames(TS)<-colnames(x_A)
colnames(TS_q)<-colnames(x_A)

ts<-cbind(sample_description,TS)
ts_q<-cbind(sample_description,TS_q)

write.csv(ts,file = "ts.csv",row.names = F)
write.csv(ts_q,file="ts_q.csv",row.names = F)

# Get the volcano plot
rownames(TS)<-cell_line
rownames(TS_q)<-cell_line

for( i in seq_len(nCond)){
  filename<-paste0("p",i)
  filename<-get_volcano_plot(ts=TS[i,],q_value=TS_q[i,],filename = cell_line[i],sig_value = 0.1)
}

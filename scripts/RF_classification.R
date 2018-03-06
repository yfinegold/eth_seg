####################################################################################
####### Object:  Run supervised classification                 
####### Author:  yelena.finegold@fao.org & remi.dannunzio@fao.org 
####### Update:  2018/03/04                                           
####################################################################################

################################################################################
source(paste0(scriptdir,"parameters1.R"),echo=TRUE)
source(paste0(scriptdir,"parameters2.R"),echo=TRUE)
####################################################################################################################
########### Supervised classification using Random Forest algorithm
####################################################################################################################

img_trng_spec <- read.table(img_tr_st)
trainer_class <- read.table(tra_tr_st)
head(trainer_class)
table(trainer_class$V3)

nband <- (ncol(img_trng_spec)-2)

names(img_trng_spec) <- c("tr_id","tr_sz",paste0("b",1:nband))
names(trainer_class) <- c("tr_id","tr_sz","tr_code")

table(trainer_class$tr_code)

################### Get training data
training <- merge(img_trng_spec,trainer_class, by='tr_id')

training <- training[training$tr_code != 0 ,c("tr_code",paste0("b",1:nband))]

training <- training[rowSums(training[,c(paste0("b",1:nband))])!=0,]
nb_class <- length(levels(as.factor(training$tr_code)))
print("training is read, reading data....")
# table(res_all_sub$results)

library(randomForest)
### Run the classification model
set.seed(1)
fit <- randomForest(as.factor(tr_code) ~ . ,ntree=400, mtry=6, data=training)
importance(fit)

### read data 
for(i in list.files(seg_dir_local, pattern = 'seg_landsat_',full.names = T)){
  print(paste0('checking file ',i))
  til <- substr(basename(i), nchar('seg_landsat')+1, nchar(basename(i))-4)
  img_sg_st <- paste0(outdir.tiles,"/",basename_fl,"_imsgst",til,".txt") #img_sg_st
  
  img_segs_spec <- read.table(img_sg_st)
  trainer_class <- read.table(tra_tr_st)
  
  nband <- (ncol(img_segs_spec)-2)
  
  names(img_segs_spec) <- c("sg_id","sg_sz",paste0("b",1:nband))
  
  ################### Get training data
  print("training is read and ratio are calculated, reading data....")
  head(img_segs_spec)
  
  library(randomForest)
  ### Run the classification model
  set.seed(1)
  # output classification in txt file format for each tile
  img_clas  <- paste0(outdir.class,"/",basename_fl,til,"_classif.txt") # results of classification as table
  
  results.prob       <- predict(fit,img_segs_spec,keep.forest=TRUE, type = "prob")
  head(results.prob[,1])
  # loop through each class to create a probability map
  j = 1
  for(j in 1:ncol(results.prob)){
    print(paste0('looking at column ', j))
    results <-results.prob[,j]
    resultsWithId.prob <- data.frame(img_segs_spec[,1] , results , as.is=TRUE)
    res_all.prob       <- resultsWithId.prob[,c(1,2)]
    res_all.prob$results <- res_all.prob$results*100
    names(res_all.prob)
    img_clas.prob  <- paste0(outdir.prob,"/",basename_fl,til,"_classif_prob_class",j,".txt") # results of classification as table
    write.table(file=img_clas.prob,res_all.prob,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)
    system(sprintf("(echo %s; echo 1; echo 1; echo 2; echo 0) | oft-reclass -oi  %s %s",
                   img_clas.prob,
                   paste0(outdir.prob,"/","tmp_reclass_prob_",til,'_class',j,".tif"),
                   i)) 
    
    system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
                   paste0(outdir.prob,"/","tmp_reclass_prob_",til,'_class',j,".tif"),
                   paste0(outdir.prob,"/",basename_fl,"_prob",til,'_class',j,".tif") 
    ))
    # remove temp files
    system(sprintf(paste0("rm ",outdir.prob,"/","tmp*.tif")))
    print(paste0('created probability file: ', paste0(outdir.prob,"/",basename_fl,"_prob",til,'_class',j,".tif") ))
  }
  # build a VRT stack of the probability output for easy viewing and processing of tiles
  system(sprintf("gdalbuildvrt -separate %s %s",
                 paste0(outdir.prob,"/",basename_fl,"_prob",til,".vrt"),
                 paste0(outdir.prob,"/",basename_fl,"_prob",til,'_class*')
  ))
  results       <- predict(fit,img_segs_spec,keep.forest=TRUE)
  resultsWithId <- data.frame(img_segs_spec[,1] , results , as.is=TRUE)
  res_all       <- resultsWithId[,c(1,2)]
  # table(res_all.prob$results)
  
  write.table(file=img_clas,res_all,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)
  head(res_all.prob)
  ########################################
  ## Reclass the selected polygons cluster
  table(res_all$results)
  
  system(sprintf("(echo %s; echo 1; echo 1; echo 2; echo 0) | oft-reclass -oi  %s %s",
                 img_clas,
                 paste0(outdir.class,"/","tmp_reclass",til,".tif"),
                 i)) ## change this varaible to loop through the landsat_seg tif files###
  system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
                 paste0(outdir.class,"/","tmp_reclass",til,".tif"),
                 paste0(outdir.class,"/",basename_fl,"_output",til,".tif") 
  ))
  print(paste0('created classification file: ', paste0(outdir.prob,"/",basename_fl,"_output",til,".tif") ))
  # remove temp files
  system(sprintf(paste0("rm ",outdir.class,"/","tmp*.tif")))
} 
# build a VRT to view the 
system(sprintf("gdalbuildvrt %s %s",
               paste0(outdir,"/",basename_fl,"_output",".vrt"),
               paste0(outdir.class,"/",basename_fl,"_output*") 
))
system(sprintf("gdalbuildvrt %s %s",
               paste0(outdir,"/",basename_fl,"_probab",".vrt"),
               paste0(outdir.prob,"/","*.vrt")
))

# ########################################
# ## Create a initial data mask
# system(sprintf("(echo 1; echo \"#1 #2 * #3 * \") | oft-calc -ot Byte %s %s",
#                im_input,
#                paste0(outdir,"/","tmp_mask.tif")))
# 
# ########################################
# ## Apply data mask
# system(sprintf("gdal_calc.py -A %s -B %s --type=Byte --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
#                paste0(outdir,"/","tmp_mask.tif"),
#                paste0(outdir,"/","tmp_reclass.tif"),
#                paste0(outdir,"/","tmp_reclass_masked.tif"),
#                "\"(A>0)*B\""))
# 
# ####################  CREATE A PSEUDO COLOR TABLE
# cols <- col2rgb(c("darkgreen","lightyellow"))
# colors()
# pct <- data.frame(cbind(c(0:1),
#                         cols[1,],
#                         cols[2,],
#                         cols[3,]
# ))
# 
# write.table(pct,paste0(outdir,"/color_table.txt"),row.names = F,col.names = F,quote = F)
# 
# ################################################################################
# ## Add pseudo color table to result
# system(sprintf("(echo %s) | oft-addpct.py %s %s",
#                paste0(outdir,"/color_table.txt"),
#                paste0(outdir,"/","tmp_reclass_masked.tif"),
#                paste0(outdir,"/","tmp_pct_reclass_masked.tif")
# ))


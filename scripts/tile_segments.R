####################################################################################
####### Object:  Run supervised classification                 
####### Author:  remi.dannunzio@fao.org                               
####### Update:  2016/10/31                                           
####################################################################################
source(paste0(scriptdir,"parameters1.R"),echo=TRUE)
source(paste0(scriptdir,"parameters2.R"),echo=TRUE)

################################################################################

####################################################################################################################
########### Extract spectral signature from the imagery 
####################################################################################################################
## Loop through all tiles
for(i in list.files('~/SARtraining/Multisensor_new/', pattern = 'lsat_s1_alos_srtm_',full.names = T)){
  # check if the file already exists
    print(paste0('checking file ',i))
  
    til <- substr(basename(i), nchar(basename(basename_fl))+1, nchar(basename(i))-4)
    if(!file.exists(paste0(outdir.tiles,"/",basename_fl,"_imsgst",til,".txt"))){
      
    seg_file <- paste0(seg_dir_local,'/', 'seg_landsat',til,'.tif')
    system(sprintf("oft-stat -i %s -o %s -um %s -nostd",
                   i,
                   paste0(outdir.tiles,"/",basename_fl,"_imsgst",til,".txt"), #img_sg_st
                   seg_file))
    }else{
      print(paste0('File: ',i, ' already exists, checking next file'))
    }
    }

# system(sprintf("oft-stat -i %s -o %s -um %s -nostd",
#                im_input,
#                img_sg_st,
#                sel_sg_code
# ))

## Extract spectral signature of the image on the training polygons ids --> the training data spectral info
system(sprintf("oft-stat -i %s -o %s -um %s -nostd",
               im_input,
               img_tr_st,
               sel_sg_code))
GDALinfo(sel_sg_train)
GDALinfo(sel_sg_id)

## Extract values of the training data on the training polygons ids --> the training data class info
system(sprintf("oft-stat -i %s -o %s -um %s -nostd",
               sel_tr_code,
               tra_tr_st,
               sel_sg_code))

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
print("training is read and ratio are calculated, reading data....")
head(img_segs_spec)
nrow(img_segs_spec)
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
  
  img_clas  <- paste0(outdir.class,"/",basename_fl,til,"_classif.txt") # results of classification as table
  # img_clas.prob  <- paste0(outdir,"/",basename_fl,til,"_classif_prob.txt") # results of classification as table
  
  results.prob       <- predict(fit,img_segs_spec,keep.forest=TRUE, type = "prob")
  head(results.prob[,1])
  j = 1
  for(j in 1:ncol(results.prob)){
    print(paste0('looking at column ', j))
    results <-results.prob[,j]
    resultsWithId.prob <- data.frame(img_segs_spec[,1] , results , as.is=TRUE)
    res_all.prob       <- resultsWithId.prob[,c(1,2)]
    res_all.prob$results <- res_all.prob$results*100
    names(res_all.prob)
    # names(res_all.prob$X1) <- 'results'
    img_clas.prob  <- paste0(outdir.prob,"/",basename_fl,til,"_classif_prob_class",j,".txt") # results of classification as table
    write.table(file=img_clas.prob,res_all.prob,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)
    system(sprintf("(echo %s; echo 1; echo 1; echo 2; echo 0) | oft-reclass -oi  %s %s",
                   img_clas.prob,
                   paste0(outdir.prob,"/","tmp_reclass_prob_",til,'_class',j,".tif"),
                   i)) ## change this varaible to loop through the landsat_seg tif files###
    
    system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
                   paste0(outdir.prob,"/","tmp_reclass_prob_",til,'_class',j,".tif"),
                   paste0(outdir.prob,"/",basename_fl,"_prob",til,'_class',j,".tif") 
    ))
    print(paste0('created probability file: ', paste0(outdir.prob,"/",basename_fl,"_prob",til,'_class',j,".tif") ))
  }
  system(sprintf("gdalbuildvrt -separate %s %s",
                 paste0(outdir.prob,"/",basename_fl,"_prob",til,".vrt"),
                 paste0(outdir.prob,"/",basename_fl,"_prob",til,'_class*')
  ))
  results       <- predict(fit,img_segs_spec,keep.forest=TRUE)
  
  resultsWithId <- data.frame(img_segs_spec[,1] , results , as.is=TRUE)
  # 
  
  res_all       <- resultsWithId[,c(1,2)]
  str(res_all)
  str(res_all.prob)
  # res_all.prob$X1 <- round(as.numeric(res_all.prob$X1*100),0)
  table(res_all.prob$results)
  
  write.table(file=img_clas,res_all,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)
  write.table(file=img_clas.prob,res_all.prob,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)
  
  # res_all[res_all$img_segs_spec...1. == 667941,]
  head(res_all)
  
  head(res_all.prob)
  # head(res_all)
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
  
  # GDALinfo(paste0(outdir,"/","tmp_reclass",til,".tif"))
} 
system(sprintf("gdalbuildvrt %s %s",
               paste0(outdir,"/",basename_fl,"_output",".vrt"),
               paste0(outdir.class,"/",basename_fl,"_output*") 
))
system(sprintf("gdalbuildvrt %s %s",
               paste0(outdir,"/",basename_fl,"_probab",".vrt"),
               paste0(outdir.prob,"/","*.vrt")
))

########################################
## Create a initial data mask
system(sprintf("(echo 1; echo \"#1 #2 * #3 * \") | oft-calc -ot Byte %s %s",
               im_input,
               paste0(outdir,"/","tmp_mask.tif")))

########################################
## Apply data mask
system(sprintf("gdal_calc.py -A %s -B %s --type=Byte --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
               paste0(outdir,"/","tmp_mask.tif"),
               paste0(outdir,"/","tmp_reclass.tif"),
               paste0(outdir,"/","tmp_reclass_masked.tif"),
               "\"(A>0)*B\""))

####################  CREATE A PSEUDO COLOR TABLE
cols <- col2rgb(c("darkgreen","lightyellow"))
colors()
pct <- data.frame(cbind(c(0:1),
                        cols[1,],
                        cols[2,],
                        cols[3,]
))

write.table(pct,paste0(outdir,"/color_table.txt"),row.names = F,col.names = F,quote = F)

################################################################################
## Add pseudo color table to result
system(sprintf("(echo %s) | oft-addpct.py %s %s",
               paste0(outdir,"/color_table.txt"),
               paste0(outdir,"/","tmp_reclass_masked.tif"),
               paste0(outdir,"/","tmp_pct_reclass_masked.tif")
))

################################################################################
## plot the histogram
val_nonforest <- subset(training, tr_code == 1)
val_forest <- subset(training, tr_code == 2)
## 1. NDVI
hist(val_crop$b21, main = "nonforest", xlab = "b21", xlim = c(min(val_crop$b21), max(val_crop$b21)), ylim = c(0, NROW(val_crop)), col = "orange")
hist(val_forest$b21, main = "forest", xlab = "b21", xlim = c(0, max(val_forest$b21)+1000), ylim = c(0, NROW(val_forest)), col = "dark green")
## 3. Bands 3 and 4 (scatterplots)
plot(b21 ~ b20, data = val_nonforest, pch = ".", col = "orange", xlim = c(0, 0.2), ylim = c(0, 0.5))
points(band4 ~ band3, data = val_forest, pch = ".", col = "dark green")
points(band4 ~ band3, data = val_wetland, pch = ".", col = "light blue")
legend("topright", legend=c("cropland", "forest", "wetland"), fill=c("orange", "dark green", "light blue"), bg="white")

########################################
## Compress final result
system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
               paste0(outdir,"/","tmp_pct_reclass_masked.tif"),
               output_rf
))

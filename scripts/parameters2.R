# ################################################################################
# 
# 
# ################################################################################
## Parameters for classification 

## create all needed directories
seg_dir_local <- paste0(rootdir,'/',"seg/tiles")#"training_manual/")
if(!dir.exists(seg_dir_local)){dir.create(seg_dir_local, recursive = T)}

outdir <- paste0(rootdir,'/',"example1")
if(!dir.exists(outdir)){dir.create(outdir, recursive = T)}
outdir.tiles <- paste0(rootdir,'/tiles')
if(!dir.exists(outdir.tiles)){dir.create(outdir.tiles, recursive = T)}
outdir.prob <- paste0(outdir,'/',"probability")
if(!dir.exists(outdir.prob)){dir.create(outdir.prob, recursive = T)}
outdir.class <- paste0(outdir,'/',"class")
if(!dir.exists(outdir.class)){dir.create(outdir.class, recursive = T)}
outdir.class.shp <- paste0(outdir,'/',"class_shp")
if(!dir.exists(outdir.class)){dir.create(outdir.class, recursive = T)}
outdir.training <- paste0(outdir,'/',"training_outputs")
if(!dir.exists(outdir.training)){dir.create(outdir.training, recursive = T)}

## INPUT IMAGE FOR SEGMENTATION
seg_dir_vrt <- paste0(rootdir,'/',"seg")
segments_rst <- paste0(seg_dir_vrt,"/","seg_landsat.vrt")

train_shp <-  paste0(outdir.training,'/',substr(basename(t1_train), 1, nchar(basename(t1_train))-4),'.shp')
train_rst <- paste0(outdir.training,'/',substr(basename(t1_train), 1, nchar(basename(t1_train))-4),'.tif')

im_input <-t1_file
sel_sg_train <- train_rst
filename <- basename(im_input)
pathname <- dirname(im_input)
basename_fl <- substr(filename,1,(nchar(filename)-4))

sel_sg_id <- paste0(outdir,"/",basename_fl,"_slsgid.tif") # identifier of selected segments
all_sg_km <- paste0(outdir,"/",basename_fl,"_alsgkm.tif") # cluster    of all segments (from k-means unsupervised classification)
all_sg_st <- paste0(outdir,"/",basename_fl,"_alsgst.txt") # spectral   of all segments (stats of the k-means over the clump)
all_sg_id <- paste0(outdir,"/",basename_fl,"_alsgid.tif") # identifier of all segments (clumped results of k-means)

masktr <- paste0(outdir,"/",basename_fl,"_masktr.tif") # masked input image, training data
cmb_masktr <- paste0(outdir,"/",basename_fl,"_cmb_masktr.tif") # masked input image, training data, with training data as the last layer
segsmasktr <- paste0(outdir,"/",basename_fl,"_masktrsegs.tif") # masked input image, training data
sel_sg_code <-  paste0(outdir,"/",basename_fl,"_slsgidcode.tif") # identifier of selected segments
sel_tr_code <-  paste0(outdir,"/",basename_fl,"_slsgtrcode.tif") # identifier of selected segments

segsmasktr <- paste0(outdir,"/",basename_fl,"_masked_segments_training.tif") # masked input image, training data
########################################
## Output
img_sg_st <- paste0(outdir,"/",basename_fl,"_imsgst.txt") # spectral of all segments (stats of the image over the clump)
img_tr_st <- paste0(outdir,"/",basename_fl,"_imtrst.txt") # spectral of training (stats of the image over the training clump)
tra_tr_st <- paste0(outdir,"/",basename_fl,"_trtrst.txt") # spectral of training (stats of the training values over the training clump)

img_clas  <- paste0(outdir,"/",basename_fl,"_classif.txt") # results of classification as table
all_sg_rf <- paste0(outdir,"/",basename_fl,"_rf.tif")      # results of classification as tif
output_rf <- paste0(outdir,"/",basename_fl,"_output.tif")   # output of process

train_man_tif  <- paste0(training_dir_local,'/',"train_",basename_fl,".tif")  # 

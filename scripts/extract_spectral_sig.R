####################################################################################
####### Object:  Run supervised classification                 
####### Author:  yelena.finegold@fao.org & remi.dannunzio@fao.org 
####### Update:  2018/03/04                                           
####################################################################################
# make sure all the parameters are set
source('/home/finegold/ethiopia/forestmapping/scripts/parameters1.R')
source('/home/finegold/ethiopia/forestmapping/scripts/parameters2.R')

################################################################################
####################################################################################################################
########### Extract spectral signature from the imagery 
####################################################################################################################
## Loop through all tiles
for(i in list.files(rawimgdir, pattern = basename_fl, full.names = T)){
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
      print(paste0('File: ',paste0(outdir.tiles,"/",basename_fl,"_imsgst",til,".txt"), ' already exists, checking next file'))
    }
}

## Extract spectral signature of the image on the training polygons ids --> the training data spectral info
print('Extracting the spectral signature of the image over the training polyogons, this may take some time depending on the number of training points')

system(sprintf("oft-stat -i %s -o %s -um %s -nostd",
               im_input,
               img_sg_st,
               sel_sg_code
))
## Extract spectral signature of the image on the training polygons ids --> the training data spectral info
system(sprintf("oft-stat -i %s -o %s -um %s -nostd",
               im_input,
               img_tr_st,
               sel_sg_code))
## Extract values of the training data on the training polygons ids --> the training data class info
print('Extracting the class over the training polyogons')
system(sprintf("oft-stat -i %s -o %s -um %s -nostd",
               sel_tr_code,
               tra_tr_st,
               sel_sg_code))

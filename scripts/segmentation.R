# segmentation using Orfeo toolbox
# it is recommended to use at least machine 4 
# make sure all the parameters are set
source('/home/finegold/ethiopia/forestmapping/scripts/parameters1.R')
source('/home/finegold/ethiopia/forestmapping/scripts/parameters2.R')

for(i in list.files(rawimgdir, pattern = 'landsat_')){
  print(paste0('checking file ',i))
  if(!file.exists(paste0(seg_dir_local,'/seg_',substr(i, 1, nchar(i)-4),'.tif'), sep="")){
    print(paste0('processing segmentation for ',i))
    system(paste("otbcli_LargeScaleMeanShift -in ",paste0(rawimgdir,'/',i)," -spatialr ", 5,
                 " -ranger ",15, " -cleanup true ",
                 " -minsize ",6, " -ram 7000000 ", #paste0(detectCores()),
                 " -mode ","raster"," -mode.raster.out ",paste0(seg_dir_local,'/seg_',substr(i, 1, nchar(i)-4),'.tif'), sep=""))
    print(paste0('File: ',paste0(seg_dir_local,'/seg_',substr(i, 1, nchar(i)-4),'.tif'), ' created! You rock!'))
    
    }else{
    print('segments already created continue to next script')
  }
  }

system(sprintf("gdalbuildvrt %s %s",
               paste0(seg_dir_vrt,"/","seg_landsat.vrt"),
               paste0(seg_dir_local,"/","*.tif")
))

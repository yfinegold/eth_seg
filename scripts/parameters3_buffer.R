# make sure all the parameters are set

###### buffer a shapefile
# new_tr <- paste0(outdir.training,'/../', 'Ehio_2017_Landcove_Forest_NonForest-1511528526_2.csv')
t1_train <- paste0(outdir.training,'/',"training_points_7_4.csv")
buff_distInMeters <- 300
combined_training.file <- paste0(outdir.training,'/','combined_training_pts.shp')
buffered_training <-  paste0(outdir.training,'/','buffer_training_',buff_distInMeters ,'m.shp')
buffered_training_rst <- paste0(outdir.training,'/','buffer_training_',buff_distInMeters ,'m.tif')
seg_buffered_training <- paste0(outdir.training,'/','buffer_segtrmask_',buff_distInMeters ,'m.shp') 
tr_shp_seg <- paste0(outdir.training,'/',"seg_landsat_training.shp")
# training_dir <- paste0(rootdir,'/',"training_data/training_combined")#"training_manual/")

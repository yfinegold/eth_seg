####################################################################################
####### Object:  Run supervised classification                 
####### Author:  yelena.finegold@fao.org & remi.dannunzio@fao.org 
####### Update:  2018/03/04                                           
####################################################################################
source('/home/finegold/ethiopia/forestmapping/scripts/parameters3_buffer.R')
## rasterize the segments using the segment ID column and other raster using the training data column
tr_shp_seg <- paste0(training_dir_local,'/','seg_training_join.shp')
buffered_segs <- readOGR(tr_shp_seg)
buffered_segs$id <- seq.int(nrow(buffered_segs))
writeOGR( buffered_segs, tr_shp_seg, substr(basename(tr_shp_seg), 1, nchar(basename(tr_shp_seg))-4), driver="ESRI Shapefile", overwrite_layer = T) 

system(sprintf("gdal_rasterize -te %s %s %s %s -tr  %s %s -a %s -a_nodata 0 -co COMPRESS=LZW -ot UInt -l %s %s %s",
               extent(raster(im_input))[1],
               extent(raster(im_input))[3],
               extent(raster(im_input))[2],
               extent(raster(im_input))[4],
               res(raster(im_input))[1],
               res(raster(im_input))[2],
               "id",
               basename(substr(tr_shp_seg, 1, nchar(tr_shp_seg)-4)),
               tr_shp_seg,
               sel_sg_code
))
gdalinfo(sel_sg_code,hist = T)

system(sprintf("gdal_rasterize -te %s %s %s %s -tr  %s %s -a %s -a_nodata 0 -co COMPRESS=LZW -ot Byte -l %s %s %s",
               extent(raster(im_input))[1],
               extent(raster(im_input))[3],
               extent(raster(im_input))[2],
               extent(raster(im_input))[4],
               res(raster(im_input))[1],
               res(raster(im_input))[2],
               "recode",
               basename(substr(tr_shp_seg, 1, nchar(tr_shp_seg)-4)),
               tr_shp_seg,
               sel_tr_code
))
gdalinfo(sel_tr_code,hist = T)

################################################################################################################################################
################################################################################################################################################
### ignore after this, the script is a work in progres... 
# basename(buffered_training)
# # new_tr.df <- read.csv(new_tr)
# t1_train.df <- read.csv(t1_train)
# # head(new_tr.df)
# head(t1_train.df)
# # combined_training <- rbind(new_tr.df,t1_train.df)
# combined_training <- t1_train.df
# 
# coordinates(combined_training) <- ~X + Y
# proj4string(combined_training) <- CRS( "+proj=longlat +datum=WGS84" )
# combined_training.UTM <- spTransform(combined_training, CRS( "+init=epsg:32637" ) ) 
# buf <- gBuffer( combined_training.UTM, width=buff_distInMeters, byid=TRUE )
# buf <- spTransform( buf, CRS( "+init=epsg:4326" )) 
# buf@data$id <- seq.int(nrow(buf))
# # write to shapefile
# writeOGR( buf, buffered_training, substr(basename(buffered_training), 1, nchar(basename(buffered_training))-4), driver="ESRI Shapefile", overwrite_layer = T) 
# writeOGR( combined_training, combined_training.file, substr(basename(combined_training.file), 1, nchar(basename(combined_training.file))-4), driver="ESRI Shapefile", overwrite_layer = T) 
# 
# #rasterize the training buffer
# system(sprintf("gdal_rasterize -te %s %s %s %s -tr  %s %s -a %s -a_nodata 0 -co COMPRESS=LZW -ot Byte -l %s %s %s",
#                extent(raster(im_input))[1],
#                extent(raster(im_input))[3],
#                extent(raster(im_input))[2],
#                extent(raster(im_input))[4],
#                res(raster(im_input))[1],
#                res(raster(im_input))[2],
#                "recode",
#                basename(substr(buffered_training, 1, nchar(buffered_training)-4)),
#                buffered_training,
#                buffered_training_rst
# ))
# gdalinfo(buffered_training_rst, hist = T)
# # mask segments
# 
# system(sprintf("gdal_calc.py -A %s --type=Byte --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
#                buffered_training_rst,
#                paste0(outdir.training,'/tmp_mask.tif'),
#                "\"(A>0)*1\""))
# system(sprintf("gdal_calc.py -A %s -B %s --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
#                paste0(outdir.training,'/tmp_mask.tif'),
#                paste0(seg_dir_local,'/seg_landsat_7_4.tif'),
#                segsmasktr,
#                "\"(A*B)\""))
# gdalinfo(segsmasktr, hist = T)
# 
# # polygonize masked segments
# # gdal_polygonize.py /home/finegold/ethiopia/forestmapping/tiles/rasterseg/seg_landsat.vrt 
# # -mask /home/finegold/ethiopia/forestmapping/training_data/training_combined/training_data_workshop_nov2017_1000mbuffer.tif 
# # -f "ESRI Shapefile" 
# # /home/finegold/ethiopia/forestmapping/tiles/rasterseg/seg_landsat.shp 
# # seg_landsat seg
# ## need to polygonize the training data segments....
# # gdal_polygonize.py [-8] [-nomask] [-mask filename] raster_file [-b band]
# # [-q] [-f ogr_format] out_file [layer] [fieldname]
# # 
# system(sprintf("gdal_polygonize.py %s -mask %s -f \"ESRI Shapefile\" %s %s",
#                segsmasktr,
#                paste0(training_dir_local,'/tmp_mask.tif'),
#                seg_buffered_training,
#                basename(substr(seg_buffered_training, 1, nchar(seg_buffered_training)-4))))
# 
# buffered_segs <- readOGR(seg_buffered_training)
# plot(buffered_segs)
# # can try 2 things to do select by location
# # using a spatial subset to select by location
# crs(combined_training) <- crs(buffered_segs)
# # plot(buffered_segs)
# # table(buffered_segs@data$DN)
# # head(buffered_segs)
# buffered_segs$id <- seq.int(nrow(buffered_segs))
# # sel <- buffered_segs[combined_training$recode %in% c(1,2,3), ]
# # head(sel)
# # nrow(sel)
# ordered_sel <- over(as(combined_training,'SpatialPoints'),buffered_segs)
# selected_segs <- buffered_segs[buffered_segs$id %in% ordered_sel$id, ]
# training_pts_selected <- over(selected_segs,combined_training)
# selected_segs$recode <- training_pts_selected$recode
# 
# writeOGR( selected_segs, tr_shp_seg, substr(basename(tr_shp_seg), 1, nchar(basename(tr_shp_seg))-4), driver="ESRI Shapefile", overwrite_layer = T) 

# gIntersects(spgeom1, spgeom2 = NULL, byid = FALSE, prepared=TRUE, returnDense=TRUE, checkValidity=FALSE)
# or try gContains / other g functions in the rgeos package













# ################################################################################
# # ## mask the image by the trainin data
# # system(sprintf("gdal_calc.py -A %s -B %s --allBands=B --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
# #                train_rst,
# #                im_input,
# #                masktr,
# #                "\"(A>0)*B\""))
# 
# # system(sprintf("gdal_merge.py -co COMPRESS=LZW -separate -o %s %s %s",
# #                cmb_masktr,
# #                masktr,
# #                train_rst))
# ##try using extract with a shpfile
# ?extract
# shp1 <- readOGR(dsn= training_dir_local,train_shp)
# ex <- extract(raster(segments_rst),readOGR(train_shp),cellnumbers=T)
# head(ex)
# 
# 
# 
# GDALinfo(masktr)
# sm <- stack(cmb_masktr)
# NAvalue(sm) <- 0
# nrow(sm)
# ?stack
# valuetable <- getValues(sm)
# ?getValues
# # new strategy... 
# # mask the training data
# # gdal_polygonize.py seg_landsat.vrt -mask orkshop_nov2017_1000mbuffer.tif -f "ESRI Shapefile" seg_landsat.shp seg_landsat seg

# system(sprintf("gdal_rasterize -te %s %s %s %s -tr  %s %s -a %s -a_nodata 0 -co COMPRESS=LZW -ot Byte -l %s %s %s",
#                extent(raster(im_input))[1],
#                extent(raster(im_input))[3],
#                extent(raster(im_input))[2],
#                extent(raster(im_input))[4],
#                res(raster(im_input))[1],
#                res(raster(im_input))[2],
#                "recode",
#                basename(substr(t1_train, 1, nchar(t1_train)-4)),
#                t1_train,
#                train_rst
# ))
# trseg<- paste0(training_dir_local,'/','training_segment_join.shp')
# sel_sg_code <-  paste0(outdir,"/",basename_fl,"_slsgidcode1.tif") # identifier of selected segments
# sel_tr_code <-  paste0(outdir,"/",basename_fl,"_slsgtrcode.tif") # identifier of selected segments
# 
# system(sprintf("gdal_rasterize -te %s %s %s %s -tr  %s %s -a %s -a_nodata 0 -co COMPRESS=LZW -ot UInt -l %s %s %s",
#                extent(raster(im_input))[1],
#                extent(raster(im_input))[3],
#                extent(raster(im_input))[2],
#                extent(raster(im_input))[4],
#                res(raster(im_input))[1],
#                res(raster(im_input))[2],
#                "id1",
#                basename(substr(trseg, 1, nchar(trseg)-4)),
#                trseg,
#                sel_sg_code
# ))
# gdalinfo(sel_sg_code,hist = T)
# 
# system(sprintf("gdal_rasterize -te %s %s %s %s -tr  %s %s -a %s -a_nodata 0 -co COMPRESS=LZW -ot Byte -l %s %s %s",
#                extent(raster(im_input))[1],
#                extent(raster(im_input))[3],
#                extent(raster(im_input))[2],
#                extent(raster(im_input))[4],
#                res(raster(im_input))[1],
#                res(raster(im_input))[2],
#                "recode",
#                basename(substr(trseg, 1, nchar(trseg)-4)),
#                trseg,
#                sel_tr_code
# ))
# gdalinfo(sel_tr_code,hist = T)
# 
# # system(sprintf("gdal_calc.py -A %s -B %s --NoDataValue=0 --co COMPRESS=LZW --outfile=\"%s\" --calc=%s",
# #                train_rst,
# #                segments_rst,
# #                paste0(outdir,"/","masked_segments_training.tif"),
# #                "\"(A>0)*B\""))
# # system(sprintf("gdal_polygonize.py %s -f %s -o %s %s %s",
# #                paste0(outdir,"/","masked_segments_training.tif"),
# #                "ESRI Shapefile",
# #                paste0(outdir,"/","masked_segments_training.shp"),
# #                "masked_segments_training",
# #                'seg'))
# 
# ?over
# tr <- readOGR(train_shp)
# seg_tr <- readOGR(paste0(outdir,"/","masked_segments_training.shp"))
# head(coordinates(tr))
# tr_seg <- over(tr,seg_tr)
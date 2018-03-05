## segment output of results for editing
####################################################################################################################
# make sure all the parameters are set
source('/home/finegold/ethiopia/forestmapping/scripts/parameters1.R')
source('/home/finegold/ethiopia/forestmapping/scripts/parameters2.R')

# ## Loop through all tiles
# for(i in list.files(seg_dir_local, pattern = 'seg_landsat_', full.names = T)){
#   # check if the file already exists
#   print(paste0('checking file ',i))
#   til <- substr(basename(i), nchar(basename(basename_fl))+1, nchar(basename(i))-4)
#   outfile <- paste0(outdir.class.shp,'/',substr(basename(i), 1, nchar(basename(i))-4),'.shp')
#   if(!file.exists(outfile)){
#     system(sprintf("gdal_polygonize.py %s -f \"ESRI Shapefile\" %s %s",
#                    i,
#                    outfile,
#                    basename(substr(outfile, 1, nchar(outfile)-4))
#                    ))
#     shp <- readOGR(outfile)
#     # shp.pol <- as(shp,'SpatialPolygons')
#     # rm(shp)
#     classified_rast <- raster(paste0(outdir.class,'/',basename_fl,'_output',til,'.tif'))
#     classified_poly <- raster(paste0(outdir.class.shp,'/',basename_fl,'_output',til,'.shp'))
#     class <- extract(classified_rast,as(shp,'SpatialPolygons'))
#     shp@data$class <- class
#     writeOGR(shp, classified_poly, substr(basename(classified_poly), 1, nchar(basename(classified_poly))-4), driver="ESRI Shapefile", overwrite_layer = T) 
#     print(paste0('successfully created file',classified_poly))
#     } 
# }

outfile <- "/home/finegold/ethiopia/forestmapping/results2/tiles/class/seg_landsat_7_4.shp"
i <- "/home/finegold/ethiopia/forestmapping/tiles/rasterseg/seg_landsat_7_4.tif"
system(sprintf("gdal_polygonize.py %s -f \"ESRI Shapefile\" %s %s",
               i,
               outfile,
               basename(substr(outfile, 1, nchar(outfile)-4))
))
shp <- readOGR(outfile)
til <- '_7_4'
# basename_fl
classified_rast <- raster(paste0(outdir.class,'/',basename_fl,'_output',til,'.tif'))
classified_poly <- paste0(outdir.class.shp,'/',basename_fl,'_output',til,'.shp')

class <- extract(classified_rast, as(shp,'SpatialPolygons'))
shp@data$class <- class
writeOGR(shp, classified_poly, substr(basename(classified_poly), 1, nchar(basename(classified_poly))-4), driver="ESRI Shapefile", overwrite_layer = T) 
print(paste0('successfully created file',classified_poly))
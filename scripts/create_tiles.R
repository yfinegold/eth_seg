# subset input raw imagery
ex1 <- extent(raster(t1_file))
xmin1 <- ex1[1] +1
for(i in 1:16){
  for(j in 1:12){
    print(paste0('Raw imagery: processing tile',i,' ', j))
    system(sprintf("gdalbuildvrt  -te %s %s %s %s -tr %s %s %s %s -srcnodata 0 -vrtnodata 0",
                   ex1[1] + (i-1),
                   ex1[3] + (j-1),
                   if((ex1[1] + i) <ex1[2]){(ex1[1] + i)}else{ex1[2]},
                   if((ex1[3] + j) <ex1[4]){(ex1[3] + j)}else{ex1[4]},
                   res(raster( paste0(rawimgdir,'/',"lsat_s1_alos_srtm.vrt")))[1],
                   res(raster( paste0(rawimgdir,'/',"lsat_s1_alos_srtm.vrt")))[2],
                   paste0(rawimgdir,'/',"lsat_s1_alos_srtm_",i,'_',j,".vrt"),
                   paste0(rawimgdir,'/',"lsat_s1_alos_srtm.vrt")
    ))
  }}

ex1 <- extent(raster( paste0(rawimgdir,"landsat.vrt")))
xmin1 <- ex1[1] +1
for(i in 1:16){
  for(j in 1:12){
    print(paste0('Segmentation: processing tile',i,' ', j))
    system(sprintf("gdalbuildvrt  -te %s %s %s %s -tr %s %s %s %s -srcnodata 0 -vrtnodata 0",
                   ex1[1] + (i-1),
                   ex1[3] + (j-1),
                   if((ex1[1] + i) <ex1[2]){(ex1[1] + i)}else{ex1[2]},
                   if((ex1[3] + j) <ex1[4]){(ex1[3] + j)}else{ex1[4]},
                   res(raster( paste0(rawimgdir,"landsat.vrt")))[1],
                   res(raster( paste0(rawimgdir,"landsat.vrt")))[2],
                   paste0(rawimgdir,"landsat_",i,'_',j,".vrt"),
                   paste0(rawimgdir,"landsat.vrt")
                   
    ))
  }}

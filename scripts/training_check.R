####################################################################################
####### Object:  Run supervised classification                 
####### Author:  yelena.finegold@fao.org & remi.dannunzio@fao.org 
####### Update:  2018/03/04                                           
####################################################################################
# make sure all the parameters are set

# visual assessments of the training data spectral libraries
################################################################################
## plot the histogram
val_forest <- subset(training, tr_code == 1)
val_nonforest <- subset(training, tr_code == 2)
val_wetland <- subset(training, tr_code == 3)

## 1. NDVI
hist(val_nonforest$b21, main = "nonforest", xlab = "b21", xlim = c(min(val_crop$b21), max(val_crop$b21)), ylim = c(0, NROW(val_crop)), col = "orange")
hist(val_forest$b21, main = "forest", xlab = "b21", xlim = c(0, max(val_forest$b21)+1000), ylim = c(0, NROW(val_forest)), col = "dark green")
## 3. Bands 3 and 4 (scatterplots)
plot(b21 ~ b20, data = val_nonforest, pch = ".", col = "orange", xlim = c(0, 0.2), ylim = c(0, 0.5))
points(band4 ~ band3, data = val_forest, pch = ".", col = "dark green")
points(band4 ~ band3, data = val_wetland, pch = ".", col = "light blue")
legend("topright", legend=c("nonforest", "forest", "wetland"), fill=c("orange", "dark green", "light blue"), bg="white")

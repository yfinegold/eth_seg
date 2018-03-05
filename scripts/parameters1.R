####################################################################################
####### Object:  Run supervised classification                 
####### Author:  yelena.finegold@fao.org & remi.dannunzio@fao.org 
####### Update:  2018/03/04                                           
####################################################################################
# make sure all the parameters are set
library(raster)
library(rgdal)
library(igraph)
library(rgeos)

# SEPALhome <- '~'
# setwd(SEPALhome)
# SEPALhome <- getwd()

####################################################################################
#######          SET PARAMETERS FOR THE IMAGES OF INTEREST
####################################################################################
####### SET WHERE YOUR SCRIPTS ARE CLONED
clonedir  <- paste0("~/safe_pc_tchad/")

####### DATA WILL BE CREATED AND STORED HERE
rootdir    <- "~/eth_20180306/data"

my_dir <- getwd()
setwd(rootdir)
rootdir <- getwd()
####### SET WHERE YOUR IMAGE DIRECTORY IS
rawimgdir   <- paste0(rootdir,'/',"raw_img")
####### SET WHERE YOUR TRAINING DIRECTORY IS
training_dir_local <- paste0(rootdir,'/', 'training')
## TRAINING DATA
t1_train <- paste0(training_dir_local,'/',"training_points_7_4.csv")
## INPUT IMAGE FOR CLASSIFICATION
t1_file  <- paste0(rootdir,'/',"lsat_s1_alos_srtm.vrt")

# seg_shp_tmp <- paste0(rootdir,'/',"tiles/rasterseg",'/seg_landsat_7_4.shp')

####### other directories
oft.script.dir <- '~/scripts_ofgt/'
ramdir <- '/ram'

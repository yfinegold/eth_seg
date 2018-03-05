####################################################################################################
####################################################################################################
## SUPERVISED CLASSIFICATION USING SEGMENTATION TO CREATE A FOREST/NONFOREST MAP OF ETHIOPIA
## ALWAYS RUN MASTER LINE BY LINE#######    Update : 2018/03/04                                  ####################
#######    contact: yelena.finegold@fao.org                      ####################
####################################################################################

####################################################################################
# FAO declines all responsibility for errors or deficiencies in the database or 
# software or in the documentation accompanying it, for program maintenance and 
# upgrading as well as for any # damage that may arise from them. FAO also declines 
# any responsibility for updating the data and assumes no responsibility for errors 
# and omissions in the data provided. Users are, however, kindly asked to report any 
# errors or deficiencies in this product to FAO.
####################################################################################

####################################################################################################
####################################################################################################
scriptdir   <- "~/ethiopia/forestmapping/scripts/"

#############################################################
### SETUP PARAMETERS
#############################################################
source(paste0(scriptdir,"download_example.R"),echo=TRUE)
source(paste0(scriptdir,"parameters1.R"),echo=TRUE)
source(paste0(scriptdir,"parameters2.R"),echo=TRUE)
source(paste0(scriptdir,"parameters3_buffer.R"),echo=TRUE)


#############################################################
### TILE THE RAW IMAGERY
#############################################################
source(paste0(scriptdir,"create_tiles.R"),echo=TRUE)

#############################################################
### RUN SEGMENTATION
#############################################################
source(paste0(scriptdir,"segmentation.R"),echo=TRUE)

#############################################################
### READ AND PREPROCESS TRAINING DATA
#############################################################
source(paste0(scriptdir,"training_buffer.R"),echo=TRUE)

#############################################################
### RUN THE CLASSIFICATION
#############################################################
source(paste0(scriptdir,"extract_spectral_sig.R"),echo=TRUE)
source(paste0(scriptdir,"RF_classification.R"),echo=TRUE)


#############################################################
### CREATE POLYGON SEGMENT OUTPUT FOR MANUAL EDITING
#############################################################
source(paste0(scriptdir,"results_poly.R"),echo=TRUE)
source(paste0(scriptdir,"training_check.R"),echo=TRUE)




############### DOWNLOAD WORKSHOP DATA
wkdir <- "~/eth_ws_20180306"
if(!dir.exists(wkdir)){dir.create(wkdir, recursive = T)}
setwd(wkdir)

# system("wget https://www.dropbox.com/s/6twsqbbar0auoza/data.zip?dl=0")
# system("mv data.zip?dl=0 data.zip" )
system("wget https://www.dropbox.com/s/daw0ya4ku4tcljz/data1.zip?dl=0")
system("mv data1.zip?dl=0 data.zip" )

system("unzip data.zip" )
# system("chmod 755  ~/gnq_ws_20170726/scripts/oft-zonal_large_list.py")

############### SET WORKING ENVIRONMENT
setwd("~/eth_ws_20180306/data/")
rootdir <- paste0(getwd(),"/")
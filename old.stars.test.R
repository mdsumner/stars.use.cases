library(raadtools)
library(dplyr)


sfiles <- sstfiles(time.resolution = "daily")  %>% as_tibble()
sfiles %>% dplyr::select(file, date) 

r <- crop(raster(sfiles$fullname[1]), extent(100, 140, -50, -38))


td <- tempdir()

r <- writeRaster(r, file.path(td, "out.tif"))
library(stars)
st_gdalwarp(filename(r), file.path(td, "a.tif"), "-t_srs \"+proj=laea +lon_0=120 +lat_0=-45 +datum=WGS84\"")

## a template raster target
tmp <- readAll(raadtools::readice(latest = TRUE))

warp_str <- sprintf("-te %f %f %f %f -ts %i %i -t_srs \"%s\" -r %s", 
                    xmin(tmp), ymin(tmp), xmax(tmp), ymax(tmp), 
                    ncol(tmp), nrow(tmp), 
                    projection(tmp), 
                    "average")
print(warp_str)

print(tmp)

tfile <- topofile()
## we have to rotate from 0-360 to project to pole properly, so timing is a bit unfair here
#system.time(test_warp <- projectRaster(rotate(raster(sfiles$fullname[1])), tmp))
library(stars)
sds <- stars::st_get_subdatasets(sfiles$fullname[1])
# $SUBDATASET_1_NAME
# [1] "NETCDF:\"/rdsi/PRIVATE/raad/data/eclipse.ncdc.noaa.gov/pub/OI-daily-v2/NetCDF/1981/AVHRR/avhrr-only-v2.19810901.nc\":sst"
# 
# $SUBDATASET_2_NAME
# [1] "NETCDF:\"/rdsi/PRIVATE/raad/data/eclipse.ncdc.noaa.gov/pub/OI-daily-v2/NetCDF/1981/AVHRR/avhrr-only-v2.19810901.nc\":anom"
# 
# $SUBDATASET_3_NAME
# [1] "NETCDF:\"/rdsi/PRIVATE/raad/data/eclipse.ncdc.noaa.gov/pub/OI-daily-v2/NetCDF/1981/AVHRR/avhrr-only-v2.19810901.nc\":err"
# 
# $SUBDATASET_4_NAME
# [1] "NETCDF:\"/rdsi/PRIVATE/raad/data/eclipse.ncdc.noaa.gov/pub/OI-daily-v2/NetCDF/1981/AVHRR/avhrr-only-v2.19810901.nc\":ice"
# 

stars::st_gdalwarp(sds[[1]], "aa.tif", options = warp_str)

# CRASH
stars::st_gdalwarp(sfiles$fullname[1], file.path(td, basename(sfiles$fullname[1])), options = warp_str)

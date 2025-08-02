## Crop raster (all raster by set) per grid cell
##
airbus_dirs <- list.files("airbus_images", full.names = TRUE)
raster_file_set <- lapply(airbus_dirs[1:3], function(x){
  img_dir <- list.files(x, full.names = TRUE)
  img_dir <- img_dir[which(grepl("IMG", img_dir))]
})

## For each directory in img_dir, read raster and mosaic
for (i in 1:length(raster_file_set)) {
  message(paste0("On", "(", i, "/", length(raster_file_set), ")"))
  
  rasters <- lapply(list.files(raster_file_set[[i]], pattern = ".TIF$", full.names = TRUE), 
                    function(x){ terra::rast(x) })
  
  assign(paste0("airbus_", i),
         value = do.call(mosaic, rasters))
}


## Write mosaic on disk
aa <- list(airbus_1 = airbus_1, airbus_2 = airbus_2, airbus_3 = airbus_3)
for (i in names(aa)) {
  terra::writeRaster(aa[[i]], paste0("airbus_images/", i, ".tif"))
}

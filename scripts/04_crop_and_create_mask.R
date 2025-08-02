# Crop image with cells of the grid the area of interest and corresponding mask

# Load package
library(sf)
library(terra)
library(dplyr)

# set temporary directory
terra::terraOptions(tempdir = "temp")

# import third aerial image
airbus_1 <- rast("airbus_images/airbus_1.tif")
# import grid
aoi_grid <- sf::read_sf("shapefiles/processed/aoi_grid.shp")
# import tree canopy shapefile
canopy <- lapply(list.files("shapefiles/processed/canopy_per_ext", "correct.shp$", 
                  full.names = TRUE), 
       function(x){
         sf::read_sf(x)
       }) %>% 
  bind_rows()
st_crs(canopy) <- "EPSG:32631"
# canopy <- sf::read_sf("shapefiles/processed/species_canopy.shp") %>% 
#   sf::st_make_valid()

# Select only grid that contain canopy
grid_with_canopy <- aoi_grid[unlist(lapply(st_intersects(aoi_grid, canopy %>% st_make_valid()),
                       function(x){length(x) != 0})), ]

plot(grid_with_canopy[, 1])
plot(canopy[, 1])

# Create necessary sub-folder
out_dir <- "airbus_images/cropped"; mask_out <- "airbus_images/mask"
suppressWarnings({dir.create(out_dir); dir.create(mask_out)})

# Crop image with each cell in grid_with_canopy
# create corresponding mask of output of the crop
prog <- 0; total <- length(grid_with_canopy$grid_id)
for (name in grid_with_canopy$grid_id) {
  prog <- prog + 1
  message(paste0("Progess: ", "(", prog, "/", total, ")"))
  
  sing_grid <- grid_with_canopy[which(grid_with_canopy$grid_id == name), ]
  cropped <- terra::crop(x = airbus_1, y = sing_grid, mask = T, snap = "out")
  ## Write cropped image
  writeRaster(cropped,
              filename = paste0(out_dir, "/", "ab1_", name, ".tif"),
              overwrite = TRUE)

  ## Create mask
  rasterized <- sing_grid %>% 
    sf::st_intersection(x = ., y = canopy) %>% 
    sf::st_make_valid() %>% 
    terra::rasterize(x = ., 
                     y = cropped, 
                     field = "Species")
  
  writeRaster(rasterized, 
              filename = paste0(mask_out, "/", "ab1_", name, ".tif"),
              overwrite = TRUE)
}


# Remove objects
rm(prog, total, name, grid_with_canopy, 
   sing_grid, rasterized,
   cropped, out_dir, mask_out)

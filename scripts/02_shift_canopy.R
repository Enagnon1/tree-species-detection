library(terra)
library(sf)

# import airbus 1 images
airbus1 <- list.files("airbus_images\\000154026_1_2_STD_A\\IMG_01_PNEO4_PMS-FS",
                      pattern = ".TIF$", full.names = TRUE)

get_extend <- lapply(airbus1, function(x){
  rst <- terra::rast(x)
  rst_ext <- terra::ext(rst)
  ext_vect <- terra::vect(rst_ext)
  terra::crs(ext_vect) <- terra::crs(rst)
  ext_sf <- sf::st_as_sf(ext_vect)
  ext_sf
})

## Import species canopy
spc_canopy <- sf::read_sf("shapefiles/processed/species_canopy.shp") %>% 
  sf::st_make_valid()

canopy_intersect <- list()

for (i in 1:length(get_extend)) {
  canopy_in <- sf::st_intersection(x = spc_canopy, y = get_extend[[i]]) %>% 
    sf::st_as_sf()
  
  # create relevant folder
  save_path <- "shapefiles/processed/canopy_per_ext"
  if(!dir.exists(save_path)){
    dir.create(save_path)
  }
 
  if(nrow(canopy_in) > 0){
    canopy_intersect[[i]] <- canopy_in
    sf::write_sf(canopy_in, paste0(save_path, "/canopy_ext_", i, ".shp"))
  }
}


# Import and correct canopy
save_path <- "shapefiles/processed/canopy_per_ext"

canopy_file <- list.files(save_path, pattern = ".shp$", full.names = TRUE)

for (cf in canopy_file) {
  # ref crs
  ref_crs <- sf::read_sf(canopy_file[1]) %>% st_crs()
  
  cp_ext <- sf::read_sf(cf) %>% 
    st_transform(crs = st_crs(ref_crs))
  
  cp_name <- gsub(".shp", "", basename(cf))
  
  
  if(cp_name == "canopy_ext_1"){
    st_geometry(cp_ext) <- st_geometry(cp_ext) + c(0, -6)
  }else if(cp_name == "canopy_ext_2"){
    st_geometry(cp_ext) <- st_geometry(cp_ext) + c(-1, -3)
  }else if(cp_name == "canopy_ext_3"){
    st_geometry(cp_ext) <- st_geometry(cp_ext) + c(-1, -8)
  }else if(cp_name == "canopy_ext_4"){
    st_geometry(cp_ext) <- st_geometry(cp_ext) + c(-2, -6)
  }else if(cp_name == "canopy_ext_7"){
    st_geometry(cp_ext) <- st_geometry(cp_ext) + c(-3, -5)
  }else if(cp_name == "canopy_ext_8"){
    st_geometry(cp_ext) <- st_geometry(cp_ext) + c(2, -8)
  }else if(cp_name == "canopy_ext_9"){
    st_geometry(cp_ext) <- st_geometry(cp_ext) + c(0, -7)
  }else if(cp_name == "canopy_ext_10"){
    st_geometry(cp_ext) <- st_geometry(cp_ext) + c(-2, -5)
  }
  
  file_name <- paste0(save_path, "/", cp_name, "_correct.shp")
  if(file.exists(file_name)){
    st_delete(file_name)
  }
  
  sf::write_sf(cp_ext, file_name)
}


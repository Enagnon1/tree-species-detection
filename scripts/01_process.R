## Load packages
library(sf)
library(terra)
library(dplyr)

## Import shapefiles
tree_point_names <- st_read("shapefiles/SpeciesName_points.shp")
species_id <- unique(tree_point_names$Species)

# Empty data frame to store tree point id and relevant tree species name
tp_name_select <- data.frame() # tp = tree point 
for (tid in species_id) {
  tp_name <- tree_point_names %>% 
    filter(Species == tid) %>% 
    slice(1)
  tp_name <- data.frame(Species = tid, 
                        Species_name = gsub("_", " ", tp_name$Species_na) # Remove underscore from name
                        )
  tp_name_select <- rbind(tp_name, tp_name_select)
}

## Import tree polygon
tree_poly <- st_read("shapefiles/Canop_polygon_m_j_palmier.shp") %>% 
  select(Species)

## Associate tree polygon to relevant name from tp_name_select
tree_poly <- left_join(x = tree_poly, y = tp_name_select, by = "Species") %>% 
  mutate(Species = case_when(is.na(Species) ~ 5,
                             TRUE ~ Species),
         Species_name = case_when(is.na(Species_name) ~ "Elaeis guineensis",
                                  TRUE ~ Species_name)
         )


## Write tree canopy shape to disk
if(!dir.exists("shapefiles/processed"))dir.create("shapefiles/processed")


st_write(tree_poly, "shapefiles/processed/species_canopy.shp")

## Create grid to crop original whole raster into small images
canopy_grid <- st_make_grid(x = tree_poly, n = 100) %>% 
  st_as_sf() %>% 
  mutate(grid_id = paste0("grid_", 1:nrow(.)))

## Import area of interest shape
aoi <- st_read("shapefiles/area_of_interest.shp") %>% 
  st_transform(crs = st_crs(canopy_grid))

## Crop grid to aoi boundary
canopy_grid <- st_intersection(canopy_grid, aoi)
plot(canopy_grid[, 1])

## Export grid
st_write(canopy_grid, "shapefiles/processed/aoi_grid.shp")



###########
# Apply the shift
polygon_shifted <- tree_poly
st_geometry(polygon_shifted) <- st_geometry(tree_poly) + c(-.5, -7)
st_crs(polygon_shifted) <- st_crs(tree_poly)
st_write(polygon_shifted, "shapefiles/processed/canopy_airbus_1.shp")

polygon_shifted <- tree_poly
st_geometry(polygon_shifted) <- st_geometry(tree_poly) + c(0, 7)
st_write(polygon_shifted, "shapefiles/processed/canopy_airbus_2.shp")

polygon_shifted <- tree_poly
st_geometry(polygon_shifted) <- st_geometry(tree_poly) + c(-2, 2)
st_crs(polygon_shifted) <- st_crs(tree_poly)
st_write(polygon_shifted, "shapefiles/processed/canopy_airbus_3.shp")

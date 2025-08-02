import numpy as np
import cv2 as cv
from pathlib import Path
import shutil
import re

## Set file path
# = "./rasterized_spc" ## where are tif
txt_dir = "./airbus_images/label" ## txt file directory
Path(txt_dir).mkdir(exist_ok=True, parents=True)
#print(Path(__file__).parent)

for grid_tif in Path("./airbus_images/mask").iterdir():
    full_txt_path = str(Path(txt_dir, f"{grid_tif.stem}.txt"))
    tif_img = cv.imread(str(grid_tif), cv.IMREAD_UNCHANGED)
    
    ## Force tree species canopy layer to BGR
    gray_image = cv.cvtColor(tif_img.astype(np.uint8), cv.COLOR_GRAY2BGR)
    ## From BGR to grayscale
    gray_image = cv.cvtColor(gray_image, cv.COLOR_BGR2GRAY)

    ## Acces different classes (diffrent pixel)
    species_classes = np.unique(gray_image)
    species_classes = species_classes[species_classes != 0]

    ## Select each class and convert to binnary mask
    print("*********")
    for species in species_classes:
        new_array = gray_image.copy()  # create a copy to keep the original array
        new_array[new_array != species] = 0

        ## Find conture
        ## Apply threshold
        thres, mask_img = cv.threshold(src=new_array, type=cv.THRESH_BINARY, thresh=species/2, maxval=new_array.max())
        outlines, _ = cv.findContours(image=mask_img, mode=cv.RETR_EXTERNAL, method=cv.CHAIN_APPROX_SIMPLE)

        print(f"{grid_tif.stem} Length: {len(outlines)}")
        ## Acces outlines' coordinates and write in txt file
        for outline in outlines:
            polygon = [(round(coord[0]/mask_img.shape[1], 6), round(coord[1]/mask_img.shape[0], 6)) \
                    for coord in outline[:, 0].tolist()]

            polygon_str = f"{species} {polygon}"
            polygon_corrected = re.sub(pattern = "[\\[(\\]),]*", repl = "", string = polygon_str)            
            
            with open(full_txt_path, "a") as f:
                f.write(f"{polygon_corrected} \n")
                f.close()


## Remove empty label file
for label in Path(txt_dir).iterdir():
    with open(str(label), "r") as f:
        content = f.read()
        if content == "":
            shutil.rmtree(str(label))
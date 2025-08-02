import cv2
import numpy as np
from pathlib import Path
from matplotlib import pyplot as plt

## Convert imgages from .tif to jpeg
# list .tiff images in relevant folder
tif_folder = Path("airbus_images/cropped")
## List all images (mask)
mask_list = [mask.stem for mask in Path("airbus_images/mask").iterdir()]
Path("dataset/images").mkdir(exist_ok=True, parents=True)
new_dir = "dataset/images"
#for item in tif_folder.iterdir():
#    print(item)
for tif_img in tif_folder.iterdir():
    if tif_img.glob("*.tif"):
        if tif_img.stem in mask_list:
            file_path = f"{new_dir}/{tif_img.stem}.jpeg"
            img = cv2.imread(str(tif_img), cv2.IMREAD_UNCHANGED)
            img[np.isnan(img)] = 0
            # Standardization the image
            img = img/np.max(img)
            #img = (img - np.mean(img))/np.std(img)
            # Convert image to RGB
            #img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            plt.imsave(file_path, img)

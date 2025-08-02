from pathlib import Path
import shutil


## Move data from cropped folder to images folder

tif_folder =  Path("airbus_images/cropped").iterdir() 
Path("airbus_images/dataset/images").mkdir(exist_ok=True, parents=True)

## List all images (mask)
label_lis = [mask.stem for mask in Path("airbus_images/label").iterdir()]
tif_lis = [mask.stem for mask in Path("airbus_images/cropped").iterdir()]
mask_lis = [mask.stem for mask in Path("airbus_images/mask").iterdir()]

print(f"LABEL: {len(label_lis)}  | TIF: {len(tif_lis)}  | MASK: {len(mask_lis)}")





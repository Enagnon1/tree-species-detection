from pathlib import Path
import shutil

## Crate sub-folder in images
def create_split(images_dir:str, labels_dir:str):
    """_summary_

    Args:
        images_dir (str): directory containing the images. It represents the parent directory 
        where the train, test, and val folders will be ccreated for image splitting.
        labels_dir (str): directory containing the label (txt file). It represents the parent directory 
        where the train, test, and val folders will be ccreated for label splitting.
    """
    global image_dir, label_dir
    image_dir = Path.cwd()/f"{images_dir}"#"dataset/images"
    label_dir = Path.cwd()/f"{labels_dir}"#"dataset/labels"
    split_folder = ["train", "val", "test"]

    for spl in split_folder:
        if Path(image_dir, spl).exists():
            shutil.rmtree(Path(image_dir, spl))
        Path(image_dir, spl).mkdir(exist_ok=True)
        
        if Path(label_dir, spl).exists():
            shutil.rmtree(Path(label_dir, spl))
        Path(label_dir, spl).mkdir(exist_ok=True)

create_split(images_dir = "species_classification/dataset/image", labels_dir = "species_classification/dataset/labels")

## Create image list to slice
images_list = []
for img in Path(image_dir).glob("*.jpeg"):
    images_list.append(img)

train_img = images_list[1:round(len(images_list)*0.6)]
remain_img = [i for i in images_list if not i in train_img]
val_img = remain_img[1:round(len(remain_img)/2)]
test_img = [i for i in remain_img if not i in val_img]

## Populate train, test and val folder with relevant images and labels
def populate_split_folder(src:list, split_type:str):
    for j in src:
        # images
        img_dest_path = image_dir/f"{split_type}"/j.name
        ## Label
        label_source_path = label_dir/f"{j.stem}.txt"
        label_des_path = label_dir/f"{split_type}"/f"{j.stem}.txt"
        try:
            shutil.move(str(j), img_dest_path)
            shutil.move(label_source_path, label_des_path)
        except FileNotFoundError as e:
            print(e)

## Populate train folder
populate_split_folder(src= train_img, split_type="train")
## Populate val folder
populate_split_folder(src= val_img, split_type="val")
## Populate test folder
populate_split_folder(src= test_img, split_type="test")

## Remote
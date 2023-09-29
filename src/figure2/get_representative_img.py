import matplotlib.pyplot as plt
import tifffile as tiff
from pathlib import Path 
import numpy as np 

T1_PATH = Path('data/raw/T1_RI Tomogram.tiff')
T2_PATH = Path('data/raw/T2_RI Tomogram.tiff')
T3_PATH = Path('data/raw/T3_RI Tomogram.tiff')
HC_PATH = Path('data/raw/HC_RI Tomogram.tiff')

MIP_T1_PATH = Path('data/raw/T1_RI MIP.tiff')
MIP_T2_PATH = Path('data/raw/T2_RI MIP.tiff')
MIP_T3_PATH = Path('data/raw/T3_RI MIP.tiff')
MIP_HC_PATH = Path('data/raw/HC_RI MIP.tiff')

def save_raw_tiff_img(img_path:Path,cmap:str, save_name:str):

    img = tiff.imread(img_path)
    fig, axs = plt.subplots(1,1,figsize = (7,7))
    plt.imshow(img, cmap = cmap)
    plt.axis('off')
    plt.savefig(f'figure/figure1/fig1b_{save_name}.pdf', dpi=300, bbox_inches='tight')

save_raw_tiff_img(MIP_T1_PATH, 'gray', 'mip_test')
save_raw_tiff_img(MIP_T1_PATH, 'gray', 'mip_T1')
save_raw_tiff_img(MIP_T2_PATH, 'gray', 'mip_T2')
save_raw_tiff_img(MIP_T3_PATH, 'gray', 'mip_T3')
save_raw_tiff_img(MIP_HC_PATH, 'gray', 'mip_HC')




def save_threshold_tiff_img(img_path:Path, z_axis:int,save_name:str,threshold:list, threshold2:list):

    img = tiff.imread(img_path)
    img = img.transpose(1,2,0)

    mask = tiff.imread(img_path)
    mask = mask.transpose(1,2,0)

    img[img < threshold[0]] = 0
    slice_img = img[:,:,int(z_axis)]
    
    mask[mask < threshold2[0]] = 0
    mask[mask > threshold2[1]] = 0
    slice_mask = mask[:,:,int(z_axis)]
    slice_img = np.where(slice_img == 0, slice_mask, slice_img)

    fig, axs = plt.subplots(1,1,figsize = (7,7))
    plt.imshow(slice_img, cmap='tab20b')
    plt.clim(13300, 14100)
    plt.show()
    plt.axis('off')
    plt.savefig(f'figure/figure1/fig1b_{save_name}.pdf', dpi=300, bbox_inches='tight')


overall_threshold = [13450]
nucleus_threshold = [13800]
membrane_threshold = [13450,13600]

save_threshold_tiff_img(T1_PATH, int(110), 'nucleus_T1', nucleus_threshold, membrane_threshold)
save_threshold_tiff_img(T2_PATH, int(100), 'nucleus_T2', nucleus_threshold, membrane_threshold)
save_threshold_tiff_img(T3_PATH, int(110), 'nucleus_T3', nucleus_threshold, membrane_threshold)
save_threshold_tiff_img(HC_PATH, int(100), 'nucleus_HC', nucleus_threshold, membrane_threshold)

save_threshold_tiff_img(T1_PATH, int(110), 'overall_T1', overall_threshold, membrane_threshold)
save_threshold_tiff_img(T2_PATH, int(100), 'overall_T2', overall_threshold, membrane_threshold)
save_threshold_tiff_img(T3_PATH, int(110), 'overall_T3', overall_threshold, membrane_threshold)
save_threshold_tiff_img(HC_PATH, int(100), 'overall_HC', overall_threshold, membrane_threshold)


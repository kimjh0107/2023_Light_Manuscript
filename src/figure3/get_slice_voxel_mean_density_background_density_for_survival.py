import numpy as np 
import matplotlib.pyplot as plt 
import cv2
from scipy import ndimage
from functools import partial
from numba import jit 
import multiprocessing
from multiprocessing import Pool
import pandas as pd 
from pathlib import Path
from tqdm import tqdm
from joblib import Parallel, delayed

import warnings
warnings.filterwarnings("ignore")
warnings.simplefilter('ignore')
with warnings.catch_warnings():
    warnings.simplefilter("ignore")


# test to tiff img 
def load_img(path):
    import tifffile as tiff
    img = np.array(tiff.imread(path))
    img = img.transpose(1,2,0)
    return img

# get x,y,z
def get_center(df):
    df_x = df['x'].tolist()
    df_y = df['y'].tolist()
    df_z = df['z'].tolist()
    return df_x, df_y, df_z

# @jit
def generate_contour(img, denoise=False, threshold=13370):    
    z, _, _ = img.shape
    
    mask_3d = np.zeros(img.shape)
    
    for i in np.arange(z):
        mask = (img[i] > threshold).astype(np.uint8)
        if denoise == True:
            mask = cv2.fastNlMeansDenoising(mask)
        mask_3d[i] = mask
    return mask_3d


# calculate radius of each axis with masks 
def get_radius(mask, center_point):
    return np.abs((np.where(mask==1) - np.array(center_point).reshape(-1, 1))).max(axis = 1)


def _in_ellipse(x, y, center, a, b):
    loc = (x - center[0])**2/(a**2) + (y - center[1])**2/(b**2) 
    if ((7/8)**2)/8 < loc <= (1/8) :
        return 1
    if ((6/8)**2)/8 < loc <= ((7/8)**2)/8 :
        return 2
    elif ((5/8)**2)/8 < loc <= ((6/8)**2)/8:
        return 3
    elif ((4/8)**2)/8 < loc <= ((5/8)**2)/8:
        return 4
    elif ((3/8)**2)/8 < loc <= ((4/8)**2)/8:
        return 5
    elif ((2/8)**2)/8 < loc <= ((3/8)**2)/8:
        return 6
    elif ((1/8)**2)/8 < loc <= ((2/8)**2)/8:
        return 7
    elif 0 < loc <= (1/8)**2:
        return 8
    else:
        return 0



def generate_shell(img, center:tuple, a,b,c):

    f = partial(_in_ellipse, center=center, a=a, b=b)
    in_sphere = np.vectorize(f)
    mask_f = in_sphere(*np.indices((276, 276))).astype(np.uint8)    

    return mask_f

def get_masks(mask):
    mask1 = np.where(mask !=1, 0, mask)
    mask2 = np.where(mask !=2, 0, mask)
    mask3 = np.where(mask !=3, 0, mask)
    mask4 = np.where(mask !=4, 0, mask)
    mask5 = np.where(mask !=5, 0, mask)
    mask6 = np.where(mask !=6, 0, mask)
    mask7 = np.where(mask !=7, 0, mask)
    mask8 = np.where(mask !=8, 0, mask)
    return mask1, mask2, mask3, mask4, mask5, mask6, mask7, mask8


def get_density(mask_img, shell_num:int):

    mask_density = (np.sum(mask_img)) / np.count_nonzero(mask == int(shell_num))
    return mask_density 


def process_single_path(path,x,y,z, i) :

    img = load_img(path)
    
    mask = generate_contour(img, denoise=True, threshold=13375)
    # center_point = (int(t1_x[0]), int(t1_y[0]), int(t1_z[0]))
    center_point = (x,y,z)
    
    a,b,c = get_radius(mask ,center_point)
    img[img < 13800] = 0
    # img[img < 13450] = 0
    # img[img > 13600] = 0
    slice_img = img[:,:,int(center_point[2])]

        
    test_mask_f = generate_shell(slice_img,center_point,a,b,c) 
    #np.unique(test_mask_f)
    
    mask1, mask2, mask3, mask4, mask5, mask6, mask7, mask8 = get_masks(test_mask_f)
    
    mask1[mask1 == 1] = 1
    mask2[mask2 == 2] = 1
    mask3[mask3 == 3] = 1
    mask4[mask4 == 4] = 1
    mask5[mask5 == 5] = 1
    mask6[mask6 == 6] = 1
    mask7[mask7 == 7] = 1
    mask8[mask8 == 8] = 1
    

    mask1_img = mask1 * slice_img
    mask2_img = mask2 * slice_img
    mask3_img = mask3 * slice_img
    mask4_img = mask4 * slice_img
    mask5_img = mask5 * slice_img
    mask6_img = mask6 * slice_img
    mask7_img = mask7 * slice_img
    mask8_img = mask8 * slice_img


    mask_density_shell1 = (np.count_nonzero(mask1_img)) / (np.count_nonzero(mask1))
    mask_density_shell2 = (np.count_nonzero(mask2_img)) / (np.count_nonzero(mask2))
    mask_density_shell3 = (np.count_nonzero(mask3_img)) / (np.count_nonzero(mask3))
    mask_density_shell4 = (np.count_nonzero(mask4_img)) / (np.count_nonzero(mask4))
    mask_density_shell5 = (np.count_nonzero(mask5_img)) / (np.count_nonzero(mask5))
    mask_density_shell6 = (np.count_nonzero(mask6_img)) / (np.count_nonzero(mask6))
    mask_density_shell7 = (np.count_nonzero(mask7_img)) / (np.count_nonzero(mask7))
    mask_density_shell8 = (np.count_nonzero(mask8_img)) / (np.count_nonzero(mask8))

    
    df2 = pd.DataFrame({'shell1':mask_density_shell1, 'shell2':mask_density_shell2, 'shell3':mask_density_shell3, 'shell4':mask_density_shell4, 'shell5':mask_density_shell5, 'shell6':mask_density_shell6, 'shell7':mask_density_shell7, 'shell8':mask_density_shell8}, index=[i])

    return df2
      
 

def main(path_list:list,t1_x,t1_y,t1_z, save_name:str):
    
    result = Parallel(n_jobs = 40) (delayed(process_single_path)(path_list[i],t1_x[i],t1_y[i],t1_z[i], i) for i in tqdm(range(len(path_list))))
        
    result = pd.concat(result)
    
    result.to_csv(f'slice_shell_density_result/slice_RI_mean_{save_name}.csv')
    
        
        
if __name__ =='__main__': 
    
    sepsis_list = pd.read_csv('sepsis_center.csv')
    healthy_list = pd.read_csv('healthy_center.csv')
    
    # merge two dataframe into one 
    qc_list = pd.concat([sepsis_list, healthy_list])
    qc_list['folder'] = qc_list['path'].str.split('/').str[6]
    qc_list['file_name'] = qc_list['path'].str.split('/').str[7]

    t1 = qc_list[qc_list['timepoint'] == 't1']
    survival_list = ['20220519', '20220526', '20220526_2', '20220602_3', '20220603_3', '20220607_2']
    t1['survival'] = t1['folder'].apply(lambda x: 1 if x in survival_list else 0)

    # add '/data/tomocube/raw/sepsis' to t1['file_name'] colume elements 
    t1['path'] = '/home/data/tomocube/'+ t1['folder'] + '/' + t1['file_name']
    t1['path'] = t1['path'].str.replace('.npy', '.tiff')
    
     # split to survival if t1['survival] is 1 
    survival = t1[t1['survival'] == 1]
    non_survival = t1[t1['survival'] == 0]


    # get dataframe columns as a list 
    survival_path = survival['path'].tolist()
    non_survival_path = non_survival['path'].tolist()

    # get x,y,z
    survival_x = survival['x'].tolist()
    survival_y = survival['y'].tolist()
    survival_z = survival['z'].tolist()

    non_survival_x = non_survival['x'].tolist()
    non_survival_y = non_survival['y'].tolist()
    non_survival_z = non_survival['z'].tolist()

    main(survival_path,survival_x,survival_y,survival_z, 'survival_threshold_13800')
    main(non_survival_path,non_survival_x,non_survival_y,non_survival_z, 'nonsurvival_threshold_13800')



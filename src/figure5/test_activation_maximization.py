import torch 
import cv2 
import act_max_util as amu          # activation maximization tools
import torch
import numpy as np 
from src.config import *
from src.device import get_device
from src.accuracy import *
from src.seed import seed_everything
from src.dataloader import get_loader
from src.model_densenet import *

seed_everything(42)

    
    
    
model = torch.load("model/final_version1/diagnosis_timepoint1_CD8_healthy_timepoint1_CD8.pt")

# input = np.load('/data/tomocube/processed/input/sepsis/20220523/20220523.131017.481.CD8-134_RI Tomogram.npy')
# input = torch.from_numpy(input).unsqueeze_(0)
# input.shape
# input.requires_grad_(True)
device = get_device()
criterion = nn.CrossEntropyLoss()
dataloaders = get_loader(int(1), 'diagnosis_timepoint1_CD8_healthy_timepoint1_CD8')


for (image, label) in list(enumerate(dataloaders['train']))[:1]:
        print(image)
        X = label[0]
        y = label[1]
        
        X = X.to(device, non_blocking = True)
        X = torch.Tensor(X).unsqueeze(1)

input = X
input.requires_grad_(True)


activation_dictionary = {}
layer_name = 'denseblock4'
model.module.features.denseblock4[-1].register_forward_hook(amu.layer_hook(activation_dictionary, layer_name))


# input.retain_grad()
# model(input)
# layer_out = activation_dictionary
# layer_out[0][130].backward(retain_graph=True)


steps = 100                 # perform 100 iterations
unit = 130                  # flamingo class of Imagenet
alpha = torch.tensor(100)   # learning rate (step size) 
verbose = True              # print activation every step
L2_Decay = True             # enable L2 decay regularizer
Gaussian_Blur = True        # enable Gaussian regularizer
Norm_Crop = True            # enable norm regularizer
Contrib_Crop = True         # enable contribution regularizer




output = amu.act_max(network=model,
                input=input,
                layer_activation=activation_dictionary,
                layer_name=layer_name,
                unit=unit,
                steps=steps,
                alpha=alpha,
                verbose=verbose,
                L2_Decay=L2_Decay,
                Gaussian_Blur=Gaussian_Blur,
               # Norm_Crop=Norm_Crop,
               # Contrib_Crop=Contrib_Crop,
                )


input.retain_grad() # non-leaf tensor
model(input)
layer_out = activation_dictionary[layer_name]
layer_out[0][unit].mean().backward(retain_graph=True)



# 143
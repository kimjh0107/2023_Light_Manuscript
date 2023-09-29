import matplotlib.pyplot as plt
import numpy as np
import torch
import torch.nn.functional as F
import torch.utils.data as torch_data
from pathlib import Path 
from tqdm import tqdm
import torch.nn as nn
import matplotlib as mpl
import matplotlib.pyplot as plt


class GradCamModel(nn.Module):
    def __init__(self, model):
        super().__init__()
        self.gradients = None
        self.tensorhook = []
        self.layerhook = []
        self.selected_out = None
        self.pretrained = model
        #   self.features = model.module.features
        self.layerhook.append(
            self.pretrained.features.denseblock4.denselayer32.register_forward_hook(
                self.forward_hook()
            )
        )  

        for p in self.pretrained.parameters():
            p.requires_grad = True

    def activations_hook(self, grad):
        self.gradients = grad

    def get_act_grads(self):
        return self.gradients

    def forward_hook(self):
        def hook(module, inp, out):
            self.selected_out = out
            self.tensorhook.append(out.register_hook(self.activations_hook))

        return hook

    def forward(self, x):
        #  features = self.features(x)
        out = self.pretrained(x)
        return out, self.selected_out


class MriData(torch.utils.data.Dataset):
    def __init__(self, X, y):
        super(MriData, self).__init__()
        self.X = torch.tensor(X, dtype=torch.float32)
        self.y = torch.tensor(y).long()

    def __len__(self):
        return self.X.shape[0]

    def __getitem__(self, idx):
        return self.X[idx], self.y[idx]


def get_device():
    return torch.device("cuda" if torch.cuda.is_available() else "cpu")


def get_masked_image(loader, device, gradcam_model, masks):
    for images, gt in tqdm(loader, total=len(loader)):
        images = images.to(device)
        
        logit = gradcam_model(images)     
        logit[1].mean().backward()
        
        activation = gradcam_model.pretrained.features(images).detach()
        act_grad  = gradcam_model.get_act_grads()
        pool_act_grad = torch.mean(act_grad, dim=[2,3,4], keepdim=True)
        activation = activation * pool_act_grad

        heatmap = torch.sum(activation, dim=1)
        heatmap = F.relu(heatmap)
        heatmap /= torch.max(heatmap)
        heatmap = F.interpolate(heatmap.unsqueeze(0),(64,64,64), mode='trilinear', align_corners=True) # mode = algorithm used for upsampling
        masks.append(heatmap.cpu().numpy())
        
    return masks, heatmap


def get_heatmap_resources(IMG_PATH:Path):
    
    img = np.load(IMG_PATH).astype(np.float32)
    img_totensor = torch.Tensor(img)
    img_totensor = img_totensor.to(device, non_blocking = True)
    
    X = torch.Tensor(img_totensor).unsqueeze(0).unsqueeze(1)
    y = torch.tensor([0])

    # load dataloader
    dataset = MriData(X, y)
    loader = torch_data.DataLoader(dataset, batch_size=16, shuffle=False)

    masks = []
    masks, heatmap = get_masked_image(loader, device, gradcam_model, masks)
    heatmap.resize_(64,64,64)
    np_heatmap = heatmap.cpu().detach().numpy()

    cmap = mpl.colormaps['jet']
    heatmap_j2 = cmap(np_heatmap,alpha = 0.5)
    
    return img, heatmap_j2


def get_gradcam_img(img,heatmap, save_name:str):
    fig, axs = plt.subplots(1,1,figsize = (7,7))
    axs.imshow(img[:,:,32], cmap = 'gray')
    axs.imshow(heatmap[:,:,32])
    plt.axis('off')
    plt.savefig(f'main_figure/figure4/fig4_gradcam_{save_name}.pdf', dpi=300, bbox_inches='tight')
    plt.show()
    
def save_img(img, color_scale:str, save_name:str):
    fig, axs = plt.subplots(1,1,figsize = (7,7))
    axs.imshow(img[:,:,32], cmap = f'{color_scale}')
    plt.axis('off')
    plt.savefig(f'main_figure/figure4/fig4_{save_name}.pdf', dpi=300, bbox_inches='tight')
    plt.show()



device = get_device()
model = torch.load(f"data/diagnosis_timepoint1_CD8_healthy_timepoint1_CD8.pt")
gradcam_model = GradCamModel(model.module).to(device)
gradcam_model.layerhook
gradcam_model.eval()


T1_IMG_PATH = Path('/data/processed/input/sepsis/20220603_3/20220603.211532.508.CD8_3-046_RI Tomogram.npy')
T2_IMG_PATH = Path('/data/processed/input/sepsis/20220510/20220510.171950.017.CD8-036_RI Tomogram.npy')
T3_IMG_PATH = Path('/data/processed/input/sepsis/20220614/20220614.142226.453.CD8-141_RI Tomogram.npy')
HC_IMG_PATH = Path('/data/processed/input/igra/re_20220610/20220610.165803.956.CD8_2-017_RI Tomogram.npy')


t1_img, t1_heatmap = get_heatmap_resources(T1_IMG_PATH)
t2_img, t2_heatmap = get_heatmap_resources(T2_IMG_PATH)
t3_img, t3_heatmap = get_heatmap_resources(T3_IMG_PATH)
hc_img, hc_heatmap = get_heatmap_resources(HC_IMG_PATH)

get_gradcam_img(t1_img, t1_heatmap, 't1')
get_gradcam_img(t2_img, t2_heatmap, 't2')
get_gradcam_img(t3_img, t3_heatmap, 't3')
get_gradcam_img(hc_img, hc_heatmap, 'hc')

save_img(t1_img, 'gray','gray_t1')
save_img(t2_img, 'gray','gray_t2')
save_img(t3_img, 'gray','gray_t3')
# save_img(hc_img, 'gray','gray_hc')

save_img(t1_img, 'tab20b','tab20b_t1')
save_img(t2_img, 'tab20b','tab20b_t2')
save_img(t3_img, 'tab20b','tab20b_t3')
# save_img(hc_img, 'tab20b','tab20b_hc')



fig, axs = plt.subplots(1,1,figsize = (7,7))
axs.imshow(t1_img[:,:,32], cmap = 'gray')
plt.axis('off')
plt.colorbar(t1_img[:,:,32], cmap = 'gray')
plt.show()



fig = plt.figure(figsize = (7,7))  
fig.set_size_inches(10,3.2)
ax = fig.add_subplot(1,2,1)
pic1 = ax.imshow(hc_img[:,:,32], cmap = 'tab20b')     
range=np.arange(0.,1.02,0.2)
plt.colorbar(pic1, ticks=range)
plt.axis('off')
plt.savefig(f'figure/figure4/fig4_tab20b_hc_colorbar.pdf', dpi=300, bbox_inches='tight')




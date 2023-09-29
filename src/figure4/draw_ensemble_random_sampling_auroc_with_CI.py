import torch
from config import *
from src.device import get_device
from src.accuracy import *
from src.seed import seed_everything
from src.dataloader import get_loader
from src.model_densenet import *
import pandas as pd
from tqdm import tqdm 
from sklearn.metrics import roc_auc_score, roc_curve, confusion_matrix
import matplotlib.pyplot as plt 

seed_everything(42)


def get_each_labels_list(dataloaders, model, criterion, device) :
    dataloader = dataloaders['test']

    outputs = []
    labels = []
    model.eval()
    epoch_loss = 0

    for X,y in dataloader : 
        X = X.to(device, non_blocking = True)
        X = torch.Tensor(X).unsqueeze(1)
        output, *_ = model(X)

        loss = criterion(output, y.to(device))
        outputs.extend(F.softmax(output, dim = 1).detach().cpu().numpy())
        labels.extend(y.cpu().numpy())
        epoch_loss += loss.item()
        
            
    # divie labels to new list 
    label_0_outputs = []
    label_0_labels = []

    label_1_outputs = []
    label_1_labels = []

    for i in range(len(labels)):
        if labels[i] == 1:
            label_1_outputs.append(outputs[i])
            label_1_labels.append(labels[i])
        else:
            label_0_outputs.append(outputs[i])
            label_0_labels.append(labels[i])
    
    return label_0_outputs, label_0_labels, label_1_outputs, label_1_labels



def random_sampling(sampling_num:int, label_0_outputs, label_0_labels, label_1_outputs, label_1_labels, random_sampling_num:int):

    SAMPLING_NUMBER = int(sampling_num)

    results = []
    labels = [1] * int(random_sampling_num) + [0] * int(random_sampling_num)
   
   

    for i in range(int(random_sampling_num)):
        target_samples = np.random.choice(np.arange(0, len(label_0_outputs)), SAMPLING_NUMBER, replace=True)
        result = np.stack(label_0_outputs)[target_samples][:,0].mean()
        results.append(result)
        

    for i in range(int(random_sampling_num)):
        target_samples = np.random.choice(np.arange(0, len(label_1_outputs)), SAMPLING_NUMBER, replace=True)
        result = np.stack(label_1_outputs)[target_samples][:,0].mean()
        results.append(result)
        


    output_probs = results
    auc_p = roc_auc_score(labels, output_probs)
    fpr, tpr, _ = roc_curve(labels, output_probs)
    
    output = np.around(output_probs)
    conf = confusion_matrix(labels, output)
    
    specificity = conf[0][0] / (conf[0][0]+ conf[0][1])
    sensitivity = conf[1][1] / (conf[1][1]+ conf[1][0])

    return auc_p, output_probs, labels, fpr, tpr, specificity, sensitivity


# covert list to csv and add new columns 'num'
def make_dataframe(output_prob, num:int):
    df = pd.DataFrame(output_prob)
    df['Num_cell'] = int(num)
    df.columns = ['score','num']
    return df 


def get_list(output_prob):
    list1 = output_prob[:len(output_prob)//2]
    list2 = output_prob[len(output_prob)//2:]
    #list2 = [1 - x for x in list2]
    new_output = list1 + list2
    return new_output



def main(task:str, task_name:str):
    
    device = get_device()
    criterion = nn.CrossEntropyLoss()
    dataloaders = get_loader(int(1), task_name)
    model = torch.load(f"model/{task}/{task_name}.pt")
    
    label_0_outputs, label_0_labels, label_1_outputs, label_1_labels = get_each_labels_list(dataloaders, model, criterion, device)


    mean_tprs_list = []
    tprs_lower_list = []
    tprs_upper_list = []
    auc_mean_list = []
    specificity_mean_list = []
    sensitivity_mean_list = []
    
    base_fpr = np.linspace(0, 1, 101)
    
    for i in tqdm(range(1,11)):
        

        tprs_list = []
        roc_auc_list = []
        specificity_list = []
        sensitivity_list = []
        
        for k in range(1,101):
            auc_p_sampling ,output_probs,labels, fpr, tpr, specificity, sensitivity = random_sampling(int(i),label_0_outputs, label_0_labels, label_1_outputs, label_1_labels, int(k))
            tpr = np.interp(base_fpr, fpr, tpr)
            tpr[0] = 0.0
            tprs_list.append(tpr)
            roc_auc_list.append(auc_p_sampling)
            specificity_list.append(specificity)
            sensitivity_list.append(sensitivity)
            
            
        auc = np.array(roc_auc_list)
        mean_auc = auc.mean(axis=0)

        specificity = np.array(specificity_list)
        mean_specificity = specificity.mean(axis=0)
        
        sensitivity = np.array(sensitivity_list)
        mean_sensitivity = sensitivity.mean(axis=0)
   
        
        tprs = np.array(tprs_list)
        mean_tprs = tprs.mean(axis=0)
        std = tprs.std(axis=0)
        tprs_upper = np.minimum(mean_tprs + std, 1)
        tprs_lower = mean_tprs - std

        auc_mean_list.append(mean_auc)
        mean_tprs_list.append(mean_tprs)
        tprs_lower_list.append(tprs_lower)
        tprs_upper_list.append(tprs_upper)
        specificity_mean_list.append(mean_specificity)
        sensitivity_mean_list.append(mean_sensitivity)


    # AUROC plot 
    plt.figure(figsize=(7,7))
    plt.rcParams["font.family"] = 'sans-serif'
    plot_color = ["deeppink", "darkorange", "cornflowerblue", "green", "blue", "green", "red", "yellow", "navy", "aqua"]

    for i in range(5):
        print(i)

        plt.plot(
            base_fpr,
            mean_tprs_list[i],
            color = plot_color[i],
            lw=2,
            alpha=1,
            label = f"Proposed method {i+1}/5 cells (area = %0.3f)" % auc_mean_list[i],
            )
        
        plt.fill_between(
            base_fpr,
            tprs_lower_list[i],
            tprs_upper_list[i],
            color = plot_color[i],
            lw=2,
            alpha=0.1,
            )

        score = np.array([1- specificity_mean_list[i], sensitivity_mean_list[i]])
        plt.plot(score[0], score[1], 'ro', color= plot_color[i])        
    plt.legend()   
    
    SOFA_score = np.array([0.56, 0.77])
    SIRS_score = np.array([0.5, 0.75])
    qSOFA_score = np.array([0.16, 0.56])
    MEWS_score = np.array([0.27, 0.80])
    
    plt.plot(SOFA_score[0], SOFA_score[1], 'ro', color='black')
    plt.annotate('SOFA',(SOFA_score[0],SOFA_score[1]), textcoords="offset points", xytext=(0,-15), ha='center')
    
    plt.plot(SIRS_score[0], SIRS_score[1], 'ro', color='black')
    plt.annotate('SIRS',(SIRS_score[0],SIRS_score[1]), textcoords="offset points", xytext=(0,-15), ha='center')
    
    plt.plot(qSOFA_score[0], qSOFA_score[1], 'ro', color='black')
    plt.annotate('qSOFA',(qSOFA_score[0],qSOFA_score[1]), textcoords="offset points", xytext=(0,-15), ha='center')
    
    plt.plot(MEWS_score[0], MEWS_score[1], 'ro', color='black')
    plt.annotate('MEWS',(MEWS_score[0],MEWS_score[1]), textcoords="offset points", xytext=(0,-15), ha='center')
    
    
    plt.plot([0, 1], [0, 1], color="black", lw=2, linestyle="--")
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel("False Positive Rate")
    plt.ylabel("True Positive Rate")
    plt.title(f'{task_name}', position=(0.5, 1.05), fontsize=12)
    plt.legend(loc="lower right")
    fig = plt.gcf()
    plt.show()
    fig.savefig(f'main_figure/AUROC_CI_{task_name}.pdf', edgecolor='black', dpi=300)

    
if __name__ == "__main__":
    
    main('final_version1','diagnosis_timepoint1_CD8_healthy_timepoint1_CD8')
    main('final_version1','mortality_timepoint1_CD8_nonsurvived_survived_CD8')

    








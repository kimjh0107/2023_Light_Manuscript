import pandas as pd 
from statsmodels.stats.anova import anova_lm
from statsmodels.formula.api import ols

df = pd.read_csv('data/processed/overall_density_random_sampling_5_cell.csv')
# df = pd.read_csv('data/processed/nucleus_density_random_sampling_5_cell_num_add_hc.csv')


def calculate_pvalue(df, num:int):
    shell = df[df['shell_num'] == int(num)]
    shell_t1 = shell[shell['timepoint'] == 't1']
    shell_t2 = shell[shell['timepoint'] == 't2']
    shell_t3 = shell[shell['timepoint'] == 't3']
    shell_hc = shell[shell['timepoint'] == 'hc']
    
    df = pd.concat([shell_t1, shell_t2,shell_t3,shell_hc], axis=0)

    model = ols('density ~ C(timepoint)', df).fit()
    result = anova_lm(model)
    return result


def get_shell_pvalue(df):
    pvalue_list = []
    for i in range(1, 9):
        pvalue = calculate_pvalue(df, int(i))
        pvalue_list.append(pvalue)

    return pvalue_list


pvalue_df = get_shell_pvalue(df)
pvalue_df



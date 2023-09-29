# 1. 각 timepoint 마다 random 으로 n개 select 
# 2. select 된것들에 대해서 100번씩 돌리고 그 값을 리스트에 저장한 이후에 평균내서 그래프 그리기
# 3. Lineplot형태로도 그리고 barplot형태로는 이제 각각의 sampling된 결과들의 평균을 ? (p-value는 이제 two tailed t-test 방법을 사용했다고함)

import pandas as pd 
import random
import numpy as np

t1 = pd.read_csv('data/RI_distribution/slice_RI_mean_t1_threshold_13800.csv')
t2 = pd.read_csv('data/RI_distribution/slice_RI_mean_t2_threshold_13800.csv')
t3 = pd.read_csv('data/RI_distribution/slice_RI_mean_t3_threshold_13800.csv')
hc = pd.read_csv('data/RI_distribution/slice_RI_mean_hc_threshold_13800.csv')

# delete columns in dataframe 
del t1['Unnamed: 0']
del t2['Unnamed: 0']
del t3['Unnamed: 0']
del hc['Unnamed: 0']

# add new columns in dataframe 
t1['timepoint'] = 't1'
t2['timepoint'] = 't2'
t3['timepoint'] = 't3'
hc['timepoint'] = 'hc'

def random_sampling(df1, df2, df3, df4, num:int):
    df1_sampling = df1.sample(n=num, replace=False)
    df2_sampling = df2.sample(n=num, replace=False)
    df3_sampling = df3.sample(n=num, replace=False)
    df4_sampling = df4.sample(n=num, replace=False)
    return df1_sampling, df2_sampling, df3_sampling, df4_sampling


def repeat_sampling(df, num:int):
    sampling_mean_list = []
    for i in range(100):
        df_sampling = df.sample(n=int(num), replace=False)
        df_sampling_mean = df_sampling.mean(axis=0)
        df_sampling_mean = df_sampling_mean.values.flatten()
        sampling_mean_list.append(df_sampling_mean)
    return sampling_mean_list
        

def get_mean_list(df1, df2, df3, df4, num:int):
    df1_mean_list = repeat_sampling(df1, int(num))
    df2_mean_list = repeat_sampling(df2, int(num))
    df3_mean_list = repeat_sampling(df3, int(num))
    df4_mean_list = repeat_sampling(df4, int(num))
    return df1_mean_list, df2_mean_list, df3_mean_list, df4_mean_list

# convert to dataframe function 
def convert_to_df(df1_list, df2_list, df3_list, df4_list):
    df1 = pd.DataFrame(df1_list)
    df2 = pd.DataFrame(df2_list)
    df3 = pd.DataFrame(df3_list)
    df4 = pd.DataFrame(df4_list)
    
    df1['timepoint'] = 't1'
    df2['timepoint'] = 't2'
    df3['timepoint'] = 't3'
    df4['timepoint'] = 'hc'
    return df1, df2, df3, df4

# add index in dataframe 
def reset_index(df1,df2,df3,df4):
    df1 = df1.reset_index()
    df2 = df2.reset_index()
    df3 = df3.reset_index()
    df4 = df4.reset_index()
    return df1,df2,df3,df4



def main(n:int):
    
    t1_mean_list, t2_mean_list, t3_mean_list, hc_mean_list = get_mean_list(t1, t2, t3, hc, int(n))
    t1, t2, t3, hc = convert_to_df(t1_mean_list, t2_mean_list, t3_mean_list, hc_mean_list)
    t1, t2, t3, hc = reset_index(t1, t2, t3, hc)
    df = pd.concat([t1, t2, t3, hc], axis=0)
        
    df = pd.DataFrame({ 'cell_num': df['index'],
                        '1':df[7], 
                        '2':df[6], 
                        '3':df[5], 
                        '4':df[4], 
                        '5':df[3], 
                        '6':df[2], 
                        '7':df[1], 
                        '8':df[0], 
                        'timepoint':df['timepoint']})

    # save dataframe into csv 
    df.to_csv(f'data/random_sampling_lineplot/sampling_{int(n)}_cell_num.csv', index=False)
    
    
if __name__ == "__main__":
    
    main(int(1))
    main(int(5))
    main(int(10))
    main(int(50))
    main(int(100))
    main(int(500))
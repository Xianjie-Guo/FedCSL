[FedCSL: A Scalable and Accurate Approach to Federated Causal Structure Learning](https://xianjie-guo.github.io/EnHome.html) <br>

# Usage
"FedCSL.m" is main function. <br>
Note that the current code has only been debugged on a 64-bit Windows system and supports only discrete datasets.<br>
----------------------------------------------
function [CausalS, Time] = FedCSL(Datasets, Alpha) <br>
* INPUT: <br>
```Matlab
Datasets: a cell array of datasets on all clients. Note that the sample size can be different for each dataset but the feature dimensions must be the same.
Alpha: the significant level, e.g., 0.01 or 0.05.
```
* OUTPUT: <br>
```Matlab
CausalS: the learned causal structure.
Time: the running time.
```

# Example for discrete dataset
```Matlab
clear;
clc;
addpath(genpath('com_func/'));

graph_path='./dataset/Child_graph.txt';
data_path='./dataset/Child_5000samples.txt';

alpha=0.01; % the significant level.
client_num=5; % the number of clients.
ground_truth=load(graph_path);
data=importdata(data_path)+1;
[datasets] = split_dataset(data, client_num);
[dag,time]=FedCSL(datasets,alpha); % dag is the learned causal structure.

% evaluate the learned causal structure.
[fdr,tpr,fpr,SHD,reverse,miss,extra,undirected,ar_f1,ar_precision,ar_recall]=eva_DAG(ground_truth,dag);
```

# Reference
* Guo, Xianjie, et al. "FedCSL: A Scalable and Accurate Approach to Federated Causal Structure Learning." *Proceedings of the 38th AAAI Conference on Artificial Intelligence (AAAI'24)* (2024).

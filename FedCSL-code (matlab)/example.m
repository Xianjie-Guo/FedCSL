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
            
            
           
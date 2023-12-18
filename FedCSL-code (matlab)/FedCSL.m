function [CausalS, Time] = FedCSL(Datasets, Alpha)
% by XianjieGuo 2023.12.18, Singapore, NTU
% FedCSL: A Scalable and Accurate Approach to Federated Causal Structure Learning

% Input:
% Datasets: a cell array of datasets on all clients. Note that the sample size can be different for each dataset but the feature dimensions must be the same.
% Alpha: the significant level, e.g., 0.01 or 0.05.

% Output:
% CausalS: the learned causal structure.
% Time: running time.

%#################################START#################################
maxK=3;
m=length(Datasets); % m is the number of clients
[~,col]=size(Datasets{1});

start=tic;

% Step 1£ºFederated Causal Neighbor Learning
W=zeros(1,m); % Store the weight of each client
PCs=cell(m,col); % Store causal neighbors for each variable learned by each client
for index_data=1:m
    dataset=Datasets{index_data};
    ns=max(dataset);
    P_Values=[]; % Record the p-value of the CI return for pairwise variables under empty set conditions
    
    % Step 1-1: Learning the Potential Causal Neighbors of Each Variable Independently.
    for i=1:col
        [pc, p_values,~,~,~]=HITONPC_G2_plus(dataset,i,Alpha,ns,col,maxK);
        PCs{index_data,i}=pc;
        P_Values=[P_Values p_values(i:end)]; % (col-1)+(col-2)+...+1
    end
    
    % Step 1-2: Calculating the Weights of Different Clients.
    [W(index_data)]=calculate_weight(P_Values, Alpha);
end


causal_adjs=cell(1,col); % Store the optimal causal neighbor set for each variable
for index_var=1:col
    % Step 1-3: Calculating the Optimal Number of Causal Neighbors for Each Variable.
    vec2num=zeros(1,col); % The maximum number of causal neighbors for each variable is col-1, but the first digit of the array is denoted as 0
    for i=1:m
        vec2num(length(PCs{i,index_var})+1)=vec2num(length(PCs{i,index_var})+1)+W(i);
    end
    [~,num_adj]=max(vec2num);
    num_adj=num_adj-1;  % num_adj is the number of causal neighbors of the current variable
    
    % Step 1-4: Determining the Optimal Causal Neighbors of Each Variable.
    vec2var=zeros(1,col);
    for i=1:m
        cur_pc=PCs{i,index_var};
        for j=1:length(cur_pc)
            vec2var(cur_pc(j))=vec2var(cur_pc(j))+W(i);
        end
    end
    [~,index]=sort(vec2var,'descend');
    causal_adjs{index_var}=index(1:num_adj);
end



% Step 2£ºFederated Global Skeleton Construction
TGS=zeros(col,col); % Tentative Global Skeleton
for index_var=1:col
    TGS(index_var,causal_adjs{index_var})=1;
end

% Correcting asymmetric edges in TGS
[skeleton]=TGS2skeleton(TGS, W, PCs, col, m);



% Step 3£ºFederated Skeleton Orientation
cpm = tril(sparse(skeleton));
% Orient the final skeleton on each client and obtain m adjacency matrices A
As=cell(1,m);
for i=1:m
    LocalScorer = bdeulocalscorer(Datasets{i}, max(Datasets{i}));
    HillClimber = hillclimber(LocalScorer, 'CandidateParentMatrix', cpm);
    As{i} = HillClimber.learnstructure();
end

% Merge m adjacency matrices A based on the weights of different clients 
As_Avg=zeros(col,col);
for i=1:m
    As_Avg=As_Avg+(As{i}*W(i));
end

% Compare the element values at the corresponding positions on the diagonal, if As_Avg(a, b)>=As_Avg(b, a) So a->b
for i=1:col
    for j=1:i-1
        if As_Avg(i,j)~=0||As_Avg(j,i)~=0
            if As_Avg(i,j)>=As_Avg(j,i)
                As_Avg(i,j)=1;
                As_Avg(j,i)=0;
            else
                As_Avg(i,j)=0;
                As_Avg(j,i)=1;
            end
        end
    end
end

CausalS=As_Avg;

Time=toc(start);

end
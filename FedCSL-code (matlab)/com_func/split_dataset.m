function [datasets] = split_dataset(orig_dataset, num_client)
% Divide the original total number into unequal segments of data from each client according to the rule of arithmetic progression

datasets=cell(1,num_client);

n=size(orig_dataset,1); 

ni=zeros(1,num_client);

ni(1)=floor(n/(2*num_client)); % The minimum amount of data held on the first client.
d=floor((2*(n-(num_client*ni(1))))/(num_client*(num_client-1)));

% Calculate the amount of data held on each client
for i=2:num_client
    ni(i)=ni(1)+(d*(i-1));
end

aux=0;
for i=1:num_client
    datasets{i}=orig_dataset((1+aux):(ni(i)+aux),:);
    aux=aux+ni(i);
end

end
function   [TGS]=TGS2skeleton(TGS, W, PCs, num_var, num_client)
% This function corrects asymmetric edges in the Tentative Global Skeleton (TGS) to construct the global skeleton.

% Record asymmetric edges in TGS
asy_edges={};
for i=1:num_var
    for j=1:i-1
        if TGS(i,j)~=TGS(j,i)
            asy_edges{end+1}=[i,j];% Add the indices of all conflicting pairs of nodes to a cell array.
        end
    end
end

% Compute the score for each pair of conflicting nodes, and simultaneously scale the scores based on weight values. Therefore, the score ¡Ê (-1, 1) is definitely an open interval on both the left and right sides.
% A Score approaching +1 indicates a high probability of an edge between them, while a Score approaching -1 suggests a high probability of no edge. A Score approaching 0 signifies an indeterminate relationship regarding the presence of an edge between them.
Score=zeros(1,length(asy_edges));
for i=1:length(asy_edges)
    var1=asy_edges{i}(1);
    var2=asy_edges{i}(2);
    
    % Record the operational results of nodes on all asymmetric edges on each client. A value of 2 indicates mutual inclusion, -2 indicates mutual exclusion, and otherwise, the client abstains from voting.
    for j=1:num_client
        if ismember(var2,PCs{j,var1})&&ismember(var1,PCs{j,var2})
            Score(i)=Score(i)+W(j)*2;
        elseif ~ismember(var2,PCs{j,var1})&&~ismember(var1,PCs{j,var2})
            Score(i)=Score(i)+W(j)*(-2);
        end
    end
end

% Adjust the Tentative Global Skeleton (TGS) based on the Score.
for i=1:length(Score)
    if Score(i)>=0
        TGS(asy_edges{i}(1),asy_edges{i}(2))=1;
        TGS(asy_edges{i}(2),asy_edges{i}(1))=1;
    else
        TGS(asy_edges{i}(1),asy_edges{i}(2))=0;
        TGS(asy_edges{i}(2),asy_edges{i}(1))=0;
    end
end


end
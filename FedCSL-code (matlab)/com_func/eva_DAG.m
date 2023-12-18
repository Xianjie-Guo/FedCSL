
function [fdr,tpr,fpr,SHD,reverse,miss,extra,undirected,ar_f1,ar_precision,ar_recall]=eva_DAG(true_DAG,learned_DAG)
% fdr: False Discovery Rate
% tpr: True Positive Rate
% fpr: False Positive Rate


% ************************SHD,,reverse,miss,extra,undirected****************************
diff_G=true_DAG-learned_DAG;
[x,y]=find(diff_G~=0);

undirected=0;
reverse=0;
miss=0;
extra=0;

for loop_i=1:length(x)
    
    if x(loop_i)==-1
        continue;
    end
    biaozhi=0;
    
    if ~isempty(find(y==(x(loop_i)), 1))
        y_index=find(y==(x(loop_i)));
        for k=1:length(y_index)
            if x(y_index(k))==y(loop_i)
                
                biaozhi=1;
                if true_DAG(x(loop_i),y(loop_i))==true_DAG(x(y_index(k)),y(y_index(k)))
                    extra=extra+1;
                else
                    reverse=reverse+1;
                    
                end
                x(y_index(k))=-1;
                y(y_index(k))=-1;
                break;
                
            end
        end
    end
    if biaozhi==0
        if true_DAG(y(loop_i),x(loop_i))==0
            if true_DAG(x(loop_i),y(loop_i))==1
                miss=miss+1;
                
            else
                extra=extra+1;
                
            end
        else
            undirected=undirected+1;
        end
    end
end

SHD=extra+miss+reverse+undirected;



% ************************fdr,tpr,fpr,ar_f1,ar_precision,ar_recall****************************
fdr=0;
tpr=0;
fpr=0;
ar_f1=0;
ar_precision=0;
ar_recall=0;

TP=0;
FN=0;
FP=0;

d=size(true_DAG,1);

for i=1:d
    for j=1:d
        if true_DAG(i,j)==1&&learned_DAG(i,j)==1
            TP=TP+1;
        end
        if true_DAG(i,j)==1&&learned_DAG(i,j)==0
            FN=FN+1;
        end
        if true_DAG(i,j)==0&&learned_DAG(i,j)==1
            FP=FP+1;
        end
    end
end

if (TP+FP)==0
    if FN==0
        ar_precision=1;
    else
        ar_precision=0;
    end
else
    ar_precision=TP/(TP+FP);
end

if (TP+FN)==0
    if FP==0
        ar_recall=1;
    else
        ar_recall=0;
    end
else
    ar_recall=TP/(TP+FN);
end

if (ar_precision+ar_recall)==0
    ar_f1=0;
else
    ar_f1=2*ar_precision*ar_recall/(ar_precision+ar_recall);
end

fdr=1-ar_precision;
tpr=ar_recall;
fpr=FP/((d*(d-1)*0.5)-(FN+TP));

end


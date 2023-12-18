function   [pc, p_values, ntest,sepset,time]=HITONPC_G2_plus(Data,target,alpha, ns, p, k)

start=tic;
cpc=[];
pc=[];

dep=zeros(1,p);
sepset=cell(1,p);
ntest=0;

p_values=[]; % Record the p-value returned by the CI of the target and each other variable under empty set conditions

for i=1:p
    if i~=target
        
        ntest=ntest+1;
        [pval, dep(i)]=my_g2test(i,target,[],Data,ns);
        
        p_values=[p_values pval];

        if isnan(pval)
            CI=1;
        else
            if pval<=alpha
                CI=0;
            else
                CI=1;
            end
        end
        
        if CI==1
            continue;
        end
        if CI==0
            cpc=[cpc,i];
        end
    end
end

% cpc

[dep_sort,var_index]=sort(dep(cpc),'descend');


for i=1:length(cpc)
    

    Y=cpc(var_index(i));
    pc=[pc Y];
    
    
    pc_length=length(pc);
    pc_tmp=pc;
    
    last_break_flag=0;
    
    for j=pc_length:-1:1
        
        X=pc(j);
        CanPC=mysetdiff(pc_tmp, X);
        
        break_flag=0;
        cutSetSize = 0;
                
        while length(CanPC) >= cutSetSize &&cutSetSize<=k
            
            SS = subsets1(CanPC, cutSetSize);    % all subsets of size cutSetSize
            
            for si=1:length(SS)
                Z = SS{si};
                
                
                if X~=Y             % idea from MMHC by YU
                    if isempty(find(Z==Y, 1))
                        continue;
                    end
                end   
                
                
                ntest=ntest+1;
                [pval]=my_g2test(X,target,Z,Data,ns);        % use G^2 to test conditional independence
                if isnan(pval)
                    CI=0;
                else
                   if pval<=alpha
                      CI=0;
                   else
                      CI=1;
                   end
                end
               
                if CI==1
                    pc_tmp=CanPC;
                    sepset{1,X}=Z;
                    break_flag=1;
                    
                    if X==Y
                        last_break_flag=1;
                    end
                    
                    break;
                end
            end
            
            if( break_flag==1 )
                break;
            end
            if( last_break_flag==1 )
                break;
            end
            
            cutSetSize = cutSetSize + 1;
        end

        if( last_break_flag==1 )
            break;
        end
    end
    
    pc=pc_tmp;
    
end

% pc = sort(pc);

time=toc(start);

end






function   [w]=calculate_weight(P_Values, alpha)
% This function is used to convert the p-value obtained by a certain client into the corresponding weight for that client.


for i=1:length(P_Values)
    if ~isnan(P_Values(i)) % NaN does not handle
        if P_Values(i)>alpha
            % The p value in the interval (¦Á, 1) is linearly mapped to the interval [0,1]
            diff1=1-alpha;% Calculate the difference in length between the original interval and the new area: diff1=b-a and diff2=d-c;
            diff2=1-0;
            P_Values(i)=(P_Values(i) - alpha) / diff1 * diff2 + 0;
        else
            % The p-value in the interval [0,¦Á] is linearly mapped to the interval [0,1] and flipped by central symmetry
            diff1=alpha-0;
            diff2=1-0;
            aux= (P_Values(i) - 0) / diff1 * diff2 + 0;
            P_Values(i) = 0.5 - (aux - 0.5); % y = mid - (x - mid)
        end
    end
end

% Remove the NaN value using a logical index
P_Values_without_nan = P_Values(~isnan(P_Values));
w=mean(P_Values_without_nan);

end
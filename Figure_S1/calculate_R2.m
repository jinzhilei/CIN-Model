function R2 = calculate_R2(observed, simulated)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to calculate R^2 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RSS = sum((observed - simulated).^2);      % 残差平方和
TSS = sum((observed - mean(observed)).^2); % 总平方和

R2 = 1 - (RSS / TSS);

end

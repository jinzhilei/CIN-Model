function [result_T, result_Y] = Solve(x0, h, xend, th, C_cap, C_csf, model_handle,initial,params)

% parameter();
% y0 = initialzation();
y0 = initialzation(initial);
[result_T, result_Y] = DDE_Euler(x0, h, xend, y0, th, C_cap, C_csf, model_handle,params);

end
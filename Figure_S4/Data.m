%% ========================================================================
%  Function: Data
%  --------------------------------------------------------------------------------------------------------------------------------
%  Description:
%  This function returns the mean neutrophil counts at each observation time point for two patient, 
%  then converted from 10^9 cells/L to 10^8 cells/kg ("./1.4" is the unit-conversion factor)
% =========================================================================
function [neutrophil_average] = Data()

neutrophil_average = [2.00,  12.03,  1.46,   11.28,  1.24,  9.18 ]./1.4; % 10^9 cells/L- --> 10^8 cells/kg
end


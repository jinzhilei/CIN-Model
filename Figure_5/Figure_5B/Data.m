%% ========================================================================
%  Function: Data
%  --------------------------------------------------------------------------------------------------------------------------------
%  Description:
%  This function returns the mean neutrophil counts at each observation time point for two patient 
%  groups (Group1 / Group2). Group1: arithmetic mean across individuals within the group at each 
%  time point, then converted from 10^9 cells/L to 10^8 cells/kg ("./1.4" is the unit-conversion factor, 5L~70kg)
% =========================================================================
function [neutrophil_group1_average, neutrophil_group2_average] = Data()

neutrophil_group1_average = [1.318, 9.712, 0.791, 8.842, 0.634, 7.108]; % 10^8 cells/kg, the unit has already been converted
neutrophil_group2_average = [1.514, 7.806, 1.239, 7.508, 1.080, 6.138];

end


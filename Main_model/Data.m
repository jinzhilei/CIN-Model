%% ========================================================================
%  Function: Data
%
%  Description:
%      Load and preprocess experimental neutrophil data. Convert unit from
%      $10^9\ \text{cells/L}$ to $10^8\ \text{cells/kg}$, and reorganize
%      data matrix for subsequent model fitting.
%
%  Input:
%      Load external file 'Data_neutrophil.mat'
%
%  Outputs:
%      T_indices    - Vector of observation time points (hours)
%      neutrophil   - Preprocessed neutrophil concentration matrix
%      exp_data     - Combined matrix of time and experimental observations
%      exp_row      - Number of rows of exp_data
%      exp_col      - Number of columns of exp_data
%      Cap_cycle    - Number of treatment cycles
% =========================================================================
function [neutrophil, T_indices, exp_data, exp_row, exp_col, Cap_cycle] = Data()
    T_indices = [0, 4, 21, 25, 42, 46];
    %% Unit: 1e9 cells/L
    load('Data_neutrophil.mat')
    % Check whether Data_neutrophil is successfully loaded
    if ~exist('Data_neutrophil','var')
        error('Failed to load variable Data_neutrophil from Data_neutrophil.mat');
    end
% neutrophil_average = [2.00,  12.03,  1.46,   11.28,  1.24,  9.18 ]./1.4; % original
% neutrophil_group1_average = [1.318, 9.712, 0.791, 8.842, 0.634, 7.108];
% neutrophil_group2_average = [1.514, 7.806, 1.239, 7.508, 1.080, 6.138];
% neutrophil = [neutrophil_average;neutrophil_group1_average;neutrophil_group2_average];
% Concatenate data into matrix: rows for subjects, columns for observations
    neutrophil = Data_neutrophil./1.4; % Convert: 10^9/L --> 10^8/kg; 5L~70kg
    %%
    Cap_cycle = length(T_indices)/2;
    exp_data = [];
for i = 1:length(T_indices)
        time_h = T_indices(i);
        expr_val = neutrophil(:,i);
        exp_data = [exp_data; time_h, expr_val'];
end
    [exp_row, exp_col] = size(exp_data);
end


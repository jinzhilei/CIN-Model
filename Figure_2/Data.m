%% ========================================================================
%  Function: Data
%
%  Description:
%      Load and preprocess experimental neutrophil data.
%      Unit conversion from 10^9 cells/L to 10^8 cells/kg.
%
%  Output:
%      data  - 2×N matrix: [time points; processed neutrophil counts]
% =========================================================================
function data = Data()
    %% Time indices (days)
    T_indices = [0, 4, 21, 25, 42, 46];

    %% Load raw neutrophil data
    load('Data_neutrophil.mat');

    %% Unit conversion: 10^9 cells/L 
    neutrophil = Data_neutrophil;

    %% Assemble output matrix [time; neutrophil]
    data = [T_indices; neutrophil];
end

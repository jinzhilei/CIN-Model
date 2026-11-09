function main_simulation()
% =========================================================================
% Main simulation program
%
% Description:
%   Run the chemotherapy-induced neutropenia model using a specified
%   parameter set, and visualize the simulation results.
%
% =========================================================================
clc;clear;close all;

%% 1. Select parameter set
parameter_index = 1; % patient: 1-30 

%% 2. Run model simulation
results = simulate_model(parameter_index);

%% 3. Plot simulation results
plot_results(results);

fprintf('Simulation completed successfully.\n');

end






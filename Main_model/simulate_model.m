function results = simulate_model(parameter_index)

% =========================================================================
% Model execution function
%
% Description:
%   Execute the hematopoietic model under repeated chemotherapy and
%   G-CSF administration.
%
%   The first 15 cycles are used as a warm-up period.
%   Only simulation results from cycles 16 to 19 are retained.
%
% Input:
%   parameter_index - Index of the selected parameter set
%
% Output:
%   results         - Structure containing simulation results
%
% =========================================================================

tic;

%% 1. Simulation settings
t_start = 0;
n_cycles = 19;
cycle_length = 21;
dt_hours = 0.1;

t_total_days = n_cycles * cycle_length;
t_end = t_total_days * 24;

th = 1;

%% 2. Experimental data
[neutrophil, exp_data] = Data();

%% 3. Parameter settings
params = loadParset();

if parameter_index < 1 || parameter_index > size(params, 1) || ...
        parameter_index ~= round(parameter_index)
    error('Invalid parameter set index.');
end

param_values = params(parameter_index, :);

%% 4. Initial conditions
initial = [1.1, 2.26, 3.54, 0.9];

%% 5. Warm-up settings
wp_cycles = 15;
wp_days = wp_cycles * cycle_length;

dt_days = dt_hours / 24;
n_zero_points = ceil(wp_days / dt_days);

%% 6. Pharmacokinetic simulations
C_cap = simulate_capecitabine_concentration( ...
    n_cycles, dt_hours, cycle_length);

C_csf = simulate_gcsf_concentration( ...
    n_cycles, dt_hours, cycle_length);

% Remove drug exposure during the warm-up period
C_cap(1:n_zero_points) = 0;
C_csf(1:n_zero_points) = 0;

%% 7. Define hematopoietic model
model = @HSCs_Cap_Gcsf_Model_new;

%% 8. Numerical simulation
fprintf('Running simulation using parameter set %d...\n', ...
    parameter_index);

[T, Y] = Solve( ...
    t_start, ...
    dt_hours, ...
    t_end, ...
    th, ...
    param_values, ...
    C_cap, ...
    C_csf, ...
    model, ...
    initial);

%% 9. Extract results from cycle 16 onward

% Starting time of cycle 16
start_day = wp_days+21;

% Corresponding simulation index
start_index = round(start_day * 24 / dt_hours) + 1;

if start_index > size(Y, 2) || start_index > numel(T)
    error('Simulation does not cover the requested analysis period.');
end

% Extract simulation results
T_plot = T(start_index:end);
Y_plot = Y(:, start_index:end);

% Reset time to zero at the beginning of cycle 16
T_plot = (T_plot - T_plot(1)) / 24;

% Extract PK profiles
C_cap_plot = C_cap(start_index:end);
C_csf_plot = C_csf(start_index:end);

%% 10. Extract model predictions

% Shift experimental observation times
day_point = exp_data + (wp_cycles + 1) * cycle_length;

% Convert observation times into simulation indices
index_day = round(day_point * 24 / dt_hours) + 1;

% Retain observations within cycles 16-19
valid_idx = index_day >= start_index & ...
            index_day <= size(Y, 2);

index_valid = index_day(valid_idx);

% Model predictions
y_pred = Y(3, index_valid);

% Experimental observations
y_obs = neutrophil(valid_idx);

% Reset observation times
day_point = day_point(valid_idx) - start_day;

%% 11. Store results

results.T = T_plot;
results.Y = Y_plot;

results.C_cap = C_cap_plot;
results.C_csf = C_csf_plot;

results.exp_data = day_point;
results.y_obs = y_obs;
results.y_pred = y_pred;

results.parameters = param_values;
results.parameter_index = parameter_index;

results.initial_conditions = initial;
results.simulation_time = toc;

results.start_cycle = wp_cycles + 1;
results.end_cycle = n_cycles;

%% 12. Save results

if ~exist('Results', 'dir')
    mkdir('Results');
end

filename = sprintf('simulation_results_%d.mat', parameter_index);

save(fullfile('Results', filename), 'results');

fprintf('Parameter set %d simulation completed in %.2f seconds.\n', ...
    parameter_index, results.simulation_time);

end


function main_Morris()
%% Moriss
tic
% Define parameter range
[param_var, pmin, pmax] = Parameter_settings();
param_ranges = [pmin pmax];

% Discretization level of parameter setting 15
num_levels = 15;

% Set the number of blocks r to 10
num_r = 10;
% Call the radial sampling method to perform sensitivity analysis
[mu, sigma] = radial_sampling_method_multi_output(@model_example, param_ranges, num_levels, num_r);
disp(mu');

toc
save('output/mu.mat','mu')
save('output/sigma.mat','sigma')
end

%% Function
function y = model_example(params)
    % MODEL_EXAMPLE 
    % input parameters:
    % x - Vector, containing three elements[x1, x2, x3]
    % output:
    % y - The output result calculated based on the model function
 
%% Solver initialisation and parameter
t_start = 0;                             % Starting time
n_cycles = 20;                           % Number of treatment cycles
dt_hours = 0.1;                          % Time step (hours)
cycle_length = 21;                       % Cycle length (day)
t_total_days = n_cycles * cycle_length;  % Total simulation time (days)
t_end = t_total_days*24;                 % Terminal time
t_hours = t_start:dt_hours:t_end;        % Initialise time vector (use hours)
t_days = t_hours/24;                     % Time scale conversion (day)
th = 1;                                  % Iteration count
%% warm-up period
wp_cycles = 15;                           % Number of warm-up cycles < n_cycles
wp_days = wp_cycles * cycle_length;
dt_days = dt_hours/24;
n_zero_points = ceil(wp_days/dt_days);   % Calculate the index corresponding to wp_cycles before calculation

%% PK simulationn
 C_cap = simulate_capecitabine_concentration(n_cycles,dt_hours,cycle_length);
 C_csf = simulate_gcsf_concentration(n_cycles,dt_hours,cycle_length);
% Set the warm up period here to not administer medication
 C_csf(1:n_zero_points) = 0;
 C_cap(1:n_zero_points) = 0;

%% Model and PD simulation
model = @HSCs_Cap_Gcsf_Model_new;
initial = [1.1,2.26,3.54,1];
[T,Y]=Solve(t_start,dt_hours,t_end,th,C_cap,C_csf,model,initial,params); %列表示时间点;
value_63 = Y(3, find(t_days == 63+16*21));  

y = value_63;   

end
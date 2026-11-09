function main_simulation()

%% Solver initialisation and parameter
t_start = 0;                             % Starting time
n_cycles = 10;                            % Number of treatment cycles
dt_hours = 0.1;                          % Time step (hours)
cycle_length = 21;                       % Cycle length (day)
t_total_days = n_cycles * cycle_length;  % Total simulation time (days)
t_end = t_total_days*24;                 % Terminal time
t_hours = t_start:dt_hours:t_end;        % Initialise time vector (use hours)
t_days = t_hours/24;                     % Time scale conversion (day)
th = 1;                                  % Iteration count

%% PK simulationn

C_cap = simulate_capecitabine_concentration(n_cycles,dt_hours,cycle_length);
[C_csf,P_csf] = simulate_gcsf_concentration(n_cycles,dt_hours,cycle_length);

%% Plot PK model and Stochastic microenvironment

picture_PK(t_days,C_cap,C_csf,P_csf);

end
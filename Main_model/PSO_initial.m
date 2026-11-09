%% ========================================================================
%  Function: PSO_initial
%
%  Description:
%      Predefine fixed simulation settings, PK profiles, initial states and
%      parameter bounds for PSO calibration.
%
%  Outputs:
%      p - Struct containing all predefined constants
% =========================================================================
function p = PSO_initial()
    %% Simulation settings
    p.t_start     = 0;                             % Start time (hours)
    p.n_cycles    = 19;                            % Total treatment cycles
    p.dt_hours    = 0.1;                           % Time step (hours)
    p.cycle_length= 21;                            % Cycle length (days)
    p.t_total_days= p.n_cycles * p.cycle_length;   % Total simulation time (days)
    p.t_end       = p.t_total_days * 24;           % Terminal time (hours)
    p.th          = 1;

    %% Load experimental data
    [p.neutrophil, p.T_indices, p.exp_data, p.exp_row, p.exp_col, p.Cap_cycle] = Data();

    %% Precompute PK profiles
    wp_cycles = 15;
    wp_days   = wp_cycles * p.cycle_length;
    dt_days   = p.dt_hours / 24;
    n_zero_points = ceil(wp_days / dt_days);

    p.C_cap = simulate_capecitabine_concentration(p.n_cycles, p.dt_hours, p.cycle_length);
    p.C_csf = simulate_gcsf_concentration(p.n_cycles, p.dt_hours, p.cycle_length);
    p.C_csf(1:n_zero_points) = 0;
    p.C_cap(1:n_zero_points) = 0;

    %% Model and initial steady-state
    p.model   = @HSCs_Cap_Gcsf_Model_new;
    p.initial = [1.1, 2.26, 3.54, 0.9];

    %% Initial parameter guess
    p.param_values = [0.8/24; 0.809; 0.35; 0.9875/24; 5; 0.007/24; 3.15444/24; 3.99; 1.5; 0.0016; 0.00009125; 3];

    %% Parameter bounds
    p.lb = [0.5/24; 0.5; 0.1; 0.3/24; 2.3056; 1e-3/24; 2/24; 2.717; 0.01; 1e-4; 1e-5; 1];
    p.ub = [2/24; 1; 0.7; 2/24; 5.82; 1e-1/24; 4/24; 5.434; 2.717; 1e-2; 1e-4; 10];
end

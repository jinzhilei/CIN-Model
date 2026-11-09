function [param_var, pmin, pmax] = Parameter_settings()
% PARAMETER_SETTINGS Define baseline parameter values and sampling bounds.
%
%   [param_var, pmin, pmax] = Parameter_settings() loads the optimized
%   parameters from 'params_Average.mat', assembles the baseline vector,
%   and computes the lower/upper sampling bounds (±5% of baseline).
%
%   Outputs:
%       param_var : 30x1 cell array of parameter names
%       pmin      : 30x1 lower bounds
%       pmax      : 30x1 upper bounds

    % PARAMETER BASELINE VALUES
    load('params_Average.mat')
    
    param_var = {
        'beta_0';          % 1
        'theta_Q';         % 2
        'n1';              % 3
        'kappa_0';         % 4
        'theta_M';         % 5
        'n2';              % 6
        'gamma_s0';        % 7
        'eta_M0';          % 8
        'gamma_0';         % 9
        'gamma_M';         % 10
        'n';               % 11
        'gamma_N';         % 12
        'v_N';             % 13
        'tau_s';           % 14
        'tau_p';           % 15
        'tau_m0';          % 16
        'Chemo_h_s';       % 17
        'Chemo_theta_C';   % 18
        'Chemo_n3';        % 19
        'CSF_v_N_max';     % 20
        'CSF_Bn';          % 21
        'CSF_gamma_s0_min';% 22
        'CSF_eta_M_max';   % 23
        'CSF_V_max';       % 24
        'CSF_Bs';          % 25
        'CSF_Bm';          % 26
        'CSF_Bv';          % 27
        'BMM_epsilon';     % 28
        'BMM_alpha';       % 29
        'BMM_theta1'       % 30
    };

    baseline = zeros(30, 1);

    % ---------------------- Original kinetic parameters (1-13) ----------------------
    baseline(1)  = params_opt(1);        % beta_0
    baseline(2)  = params_opt(2);        % theta_Q
    baseline(3)  = 2;                    % n1
    baseline(4)  = 0.4/24;               % kappa_0
    baseline(5)  = params_opt(3);        % theta_M
    baseline(6)  = 1;                    % n2
    baseline(7)  = 0.07/24;              % gamma_s0
    baseline(8)  = 1.6647/24;            % eta_M0
    baseline(9)  = 0.0064/24;            % gamma_0
    baseline(10) = 0.0064/24;            % gamma_M
    baseline(11) = 4;                    % n
    baseline(12) = params_opt(4);        % gamma_N
    baseline(13) = 0.364/24;             % v_N

    % ---------------------- Time constants (14-16) ----------------------
    baseline(14) = 2.8*24;               % tau_s
    baseline(15) = 5*24;                 % tau_p
    baseline(16) = 6*24;                 % tau_m0

    % ---------------------- Chemotherapy PD model (17-19) ----------------------
    baseline(17) = params_opt(6);        % Chemo_h_s
    baseline(18) = params_opt(5);        % Chemo_theta_C
    baseline(19) = 3;                    % Chemo_n3

    % ---------------------- G-CSF PD model (20-27) ----------------------
    baseline(20) = 11.5451/24 - 0.364/24;% CSF_v_N_max
    baseline(21) = params_opt(9);        % CSF_Bn
    baseline(22) = 0.03/24;              % CSF_gamma_s0_min
    baseline(23) = params_opt(7);        % CSF_eta_M_max
    baseline(24) = 3.8;                  % CSF_V_max
    baseline(25) = params_opt(8);        % CSF_Bs
    baseline(26) = params_opt(8);        % CSF_Bm
    baseline(27) = params_opt(8);        % CSF_Bv

    % ---------------------- Bone marrow microenvironment (28-30) ----------------------
    baseline(28) = params_opt(10);       % BMM_epsilon
    baseline(29) = params_opt(11);       % BMM_alpha
    baseline(30) = params_opt(12);       % BMM_theta1

    %% Sampling bounds (±5%)
    pmin = baseline .* 0.95;
    pmax = baseline .* 1.05;
end
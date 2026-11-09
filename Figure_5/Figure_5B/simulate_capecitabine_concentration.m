%% ========================================================================
%  Function: simulate_capecitabine_concentration
%
%  Description:
%      Simulate time-varying plasma concentration of capecitabine using a
%      first-order absorption and elimination pharmacokinetic model.
%
%  Inputs:
%      n_cycles     - Number of treatment cycles
%      dt_hours     - Time step (hours)
%      cycle_length - Length of each treatment cycle (days)
%
%  Outputs:
%      C_cap        - Vector of simulated capecitabine plasma concentration
%      t_hours      - Time vector corresponding to concentration (hours)
% =========================================================================
function [C_cap, t_hours] = simulate_capecitabine_concentration(n_cycles, dt_hours, cycle_length)
    % Pharmacokinetic parameters for capecitabine
    Fc = 0.8;                 % Bioavailability
    Vcd = 186000;             % Volume of distribution (mL)
    ka_c = 2.75;              % Absorption rate constant (h^{-1})
    kc_c = 0.2;               % Elimination rate constant (h^{-1})
    Dose_cap = 1500000;       % Single dose

    % Time configuration
    t_end_hours = n_cycles * cycle_length * 24;  % Total simulation time (hours)
    t_hours = 0:dt_hours:t_end_hours;            % Time vector (hours)
    C_cap = zeros(size(t_hours));                % Initialize concentration vector

    % Dosing regimen: Days 1 to 14 in each cycle, twice daily (12 h interval)
    for i = 1:n_cycles
        cycle_start_hours = (i-1) * cycle_length * 24;  % Start time of cycle (hours)
        for day = 1:14  % Dosing on day 1 to day 14
            for dose_time = [0, 12]  % Two doses per day at 0 h and 12 h
                dose_t = cycle_start_hours + day*24 + dose_time;  % Dose administration time (hours)
                % Concentration contribution from this dose at all later time points
                idx = t_hours >= dose_t;  % Indices of time points after dosing
                delta_t = t_hours(idx) - dose_t;  % Time elapsed after dose (hours)
                % First-order absorption-elimination model
                C_contribution = (Fc * Dose_cap / Vcd) * (ka_c / (kc_c - ka_c)) ...
                    * (exp(-ka_c * delta_t) - exp(-kc_c * delta_t));
                C_cap(idx) = C_cap(idx) + C_contribution;  % Superposition principle
            end
        end
    end
end

function [C_csf,P_csf] = simulate_gcsf_concentration(n_cycles,dt_hours,cycle_length)

%% Parameter setting

V1 = 5070;                         % Distribution volume of central compartment (mL)
V2 = 4020;                         % Distribution volume of peripheral compartment (mL)
k12 = 0.0504;          % Transit rate from V_1 to V_2 (1/h)
k21 = 0.8911;           % Transit rate from V_2 to V_1 (1/h)
ke_g = 0.1063;          % Linear clearance rate (1/h)
kmax_g = 4.7488;         % Maximum nonlinear elimination rate (ng/mL/h)
theta_G = 2.2709;        % Half-saturation constant for G-CSF elimination (ng/mL)
Fg = 0.4888;            % Bioavailability of G-CSF
Vgd = 1788;           % Distribution volume of G-CSF (mL)
ka_g = 0.107;         % G-CSF absorption rate constant (1/h)

%% Parameter setting
Dose_csf_1 = 300000;    % Dose per injection 300000 (ng)
Dose_csf_2 = 150000;    % Dose per injection 150000 (ng)
Dose_csf_3 = 75000;     % Dose per injection 75000 (ng)

Dose = [Dose_csf_1, Dose_csf_2, Dose_csf_3];

%% Time setting
t_end = n_cycles * cycle_length * 24;  % Total time (h)
t = 0:dt_hours:t_end;                  % Time vector (h)

%% Initialization variable
Num = length(t);
C_csf = zeros(Num,3);
P_csf = zeros(Num,3);
G = zeros(1,Num);  % Drug concentration in the central compartment
P = zeros(1,Num);  % Drug concentration in the peripheral compartment
I = zeros(1,Num);  % Absorption kinetics

%% Injection time point
injection_times = 0:cycle_length*24:t_end;

%% Simulated absorption kinetics
for k = 1:3

    Dose_csf = Dose(k);

    for j = 1:length(injection_times)
        time_diff = max(t - injection_times(j), 0); % Make sure the time difference is not negative
        I = I + Fg * Dose_csf / Vgd * ka_g * exp(-ka_g * time_diff) .* (t >= injection_times(j));
    end

    for i = 2:length(t)
        [k1_G, k1_P] = derivatives(G(i-1), P(i-1), I(i-1), V1, V2, k12, k21, ke_g, kmax_g, theta_G);
        [k2_G, k2_P] = derivatives(G(i-1) + 0.5*dt_hours*k1_G, P(i-1) + 0.5*dt_hours*k1_P, I(i-1), V1, V2, k12, k21, ke_g, kmax_g, theta_G);
        [k3_G, k3_P] = derivatives(G(i-1) + 0.5*dt_hours*k2_G, P(i-1) + 0.5*dt_hours*k2_P, I(i-1), V1, V2, k12, k21, ke_g, kmax_g, theta_G);
        [k4_G, k4_P] = derivatives(G(i-1) + dt_hours*k3_G, P(i-1) + dt_hours*k3_P, I(i-1), V1, V2, k12, k21, ke_g, kmax_g, theta_G);
        G(i) = G(i-1) + (dt_hours/6) * (k1_G + 2*k2_G + 2*k3_G + k4_G);
        P(i) = P(i-1) + (dt_hours/6) * (k1_P + 2*k2_P + 2*k3_P + k4_P);
    end

    C_csf(:,k) = G';
    P_csf(:,k) = P';

    % Clear data
    G = zeros(1,Num);
    P = zeros(1,Num);
    I = zeros(1,Num);

end

end
%% PK equation

function [dGdt, dPdt] = derivatives(G, P, I, V1, V2, k12, k21, ke_g, kmax_g, theta_G)
dGdt = I - k12 * G + k21 * V2 / V1 * P - ke_g * G - kmax_g * G / (G + theta_G);
dPdt = k12 * V1 / V2 * G - k21 * P;
end

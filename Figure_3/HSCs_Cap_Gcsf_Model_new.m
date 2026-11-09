%% ========================================================================
%  Function: HSCs_Cap_Gcsf_Model_new
%
%  Description:
%      Right-hand side of the delay differential equation (DDE) model for
%      hematopoietic stem cell dynamics under capecitabine chemotherapy and G-CSF stimulation.
%
%  Inputs:
%      x           - Current time
%      y           - State history matrix (state × time history)
%      th          - Time index for drug concentration arrays
%      par         - Vector of fitted model parameters
%      C_cap       - Time series of capecitabine plasma concentration
%      C_csf       - Time series of G-CSF concentration
%
%  Outputs:
%      z           - Vector of state derivatives [dQ/dx; dM/dx; dN/dx; dP/dx]
%  State variables and their unit scales (critical! all scaling factors
%  are determined solely by the difference in unit scale):
%    Q : Quiescent cell pool       unit scale 10^6   
%    M : Mature neutrophil in bone marrow reservior  (storage compartment)     unit scale 10^9/kg  
%    N : Circulating neutrophils in peripheral blood                                               unit scale 10^8/kg   
%    P : Bone marrow microenvironment state variables                                      dimensionless 
%
%  General rule for scaling factors:
%    factor = unit scale of input pool / unit scale of target pool
%           = 10^(input exponent - target exponent)
%    -- It is a unit-conversion factor, NOT a kinetic parameter; it must be
%       fixed and must not be included in parameter fitting.
% =========================================================================
function z = HSCs_Cap_Gcsf_Model_new(x, y, th, par, C_cap, C_csf)
    %% Extract current states
    Q = y(1,end);
    M = y(2,end);
    N = y(3,end);
    P = y(4,end);

    %% Unpack fitted parameters
    beta_0      = par(1);
    theta_Q     = par(2);
    theta_M     = par(3);
    gamma_N     = par(4);
    Chemo_theta_C = par(5);
    Chemo_h_s   = par(6);
    CSF_eta_M_max = par(7);
    CSF_Bs      = par(8);
    CSF_Bm      = par(8);
    CSF_Bv      = par(8);
    CSF_Bn      = par(9);
    BMM_epsilon = par(10);
    BMM_alpha   = par(11);
    BMM_theta1  = par(12);

    %% Fixed frozen parameters
    kappa_0         = 0.4/24;
    gamma_M         = 0.0064/24;
    gamma_0         = 0.0064/24;
    gamma_s0        = 0.07/24;
    eta_M0          = 1.6647/24;
    v_N             = 0.364/24;
    n1              = 2;
    n2              = 1;
    tau_s           = 2.8*24;
    tau_p           = 5*24;
    tau_m0          = 6*24;
    tau_n           = tau_p + tau_m0;
    Chemo_n3        = 3;
    CSF_V_max       = 3.8;
    CSF_gamma_s0_min = 0.03/24;
    CSF_v_N_max     = 11.5451/24;

    %% Extract delayed states
    [~, n] = size(y);
    taus_scale = round(tau_s * 10);
    taun_scale = round(tau_n * 10);
    Q_tau_s  = y(1, n - taus_scale);
    P_tau_s  = y(4, n - taus_scale);
    M_tau_n  = y(2, n - taun_scale);
    Q_tau_n  = y(1, n - taun_scale);

    %% Pharmacodynamic model of chemotherapy and G-CSF
    if C_cap(th) > 0.01
        if C_csf(th) > 0.01
            Gamma_S = CSF_gamma_s0_min + ((gamma_s0 + Chemo_h_s * C_cap(th)) - CSF_gamma_s0_min) * (CSF_Bs / (CSF_Bs + C_csf(th)));
            Eta_M   = eta_M0 * P * (Chemo_theta_C^Chemo_n3/(Chemo_theta_C^Chemo_n3 + C_cap(th)^Chemo_n3)) + ...
                      (CSF_eta_M_max - eta_M0 * P * (Chemo_theta_C^Chemo_n3/(Chemo_theta_C^Chemo_n3 + C_cap(th)^Chemo_n3))) * (C_csf(th)/(C_csf(th)+CSF_Bm));
            Tau_m   = tau_m0 / (1 + (CSF_V_max - 1)*(C_csf(th)/(C_csf(th)+CSF_Bv)));
            v_N     = v_N + (CSF_v_N_max - v_N) * (C_csf(th)/(C_csf(th)+CSF_Bn));
        else
            Gamma_S = gamma_s0 + Chemo_h_s * C_cap(th);
            Eta_M   = eta_M0 * P * (Chemo_theta_C^Chemo_n3/(Chemo_theta_C^Chemo_n3 + C_cap(th)^Chemo_n3));
            Tau_m   = tau_m0;
            v_N     = v_N;
        end
    else
        if C_csf(th) > 0.01
            Gamma_S = CSF_gamma_s0_min + (gamma_s0 - CSF_gamma_s0_min) * (CSF_Bs / (CSF_Bs + C_csf(th)));
            Eta_M   = eta_M0 * P+ (CSF_eta_M_max - eta_M0* P) * (C_csf(th)/(C_csf(th)+CSF_Bm));
            Tau_m   = tau_m0 / (1 + (CSF_V_max - 1)*(C_csf(th)/(C_csf(th)+CSF_Bv)));
            v_N     = v_N + (CSF_v_N_max - v_N) * (C_csf(th)/(C_csf(th)+CSF_Bn));
        else
            Gamma_S = gamma_s0;
            Eta_M   = eta_M0 * P;
            Tau_m   = tau_m0;
            v_N     = v_N;
        end
    end

    %% Define proliferation and transfer terms
    beta         = beta_0 * P * theta_Q.^n1 ./ (theta_Q.^n1 + Q.^n1);
    beta_tau_s   = beta_0 *  P_tau_s * theta_Q.^n1 ./ (theta_Q.^n1 + Q_tau_s.^n1);
    kappa_M      = kappa_0 * theta_M.^n2 ./ (theta_M.^n2 + M.^n2);
    kappa_M_tau_n= kappa_0 * theta_M.^n2 ./ (theta_M.^n2 + M_tau_n.^n2);

    Q_out = beta + kappa_M;
    Q_in  = 2 * exp(-Gamma_S .* tau_s) .* beta_tau_s;

    M_out = gamma_M + v_N;
    M_in  = exp(Eta_M .* tau_p - gamma_0 .* Tau_m) .* kappa_M_tau_n;

    N_out = gamma_N;
    N_in  = v_N;

    P_in  = BMM_epsilon .* Q ./ BMM_theta1 ./ (1 + Q./BMM_theta1) .* (1 - P);
    P_out = BMM_alpha .* P;

    %% State derivatives of DDE system
    z(1,1) = -Q_out .* Q + Q_in .* Q_tau_s;
    z(2,1) = -M_out .* M + M_in .* Q_tau_n * 1e-3;
    z(3,1) = -N_out .* N + N_in .* M * 10;
    z(4,1) = -P_out + P_in;
end


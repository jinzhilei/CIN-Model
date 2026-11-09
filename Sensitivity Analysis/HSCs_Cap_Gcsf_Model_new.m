function z = HSCs_Cap_Gcsf_Model_new(x,y,th,C_cap,C_csf,params)
%% Params
par.beta_0         = params(1);     % 1
par.theta_Q       = params(2);     % 2
par.n1                = params(3);     % 3
par.kappa_0      = params(4);     % 4
par.theta_M       = params(5);     % 5
par.n2                = params(6);     % 6
par.gamma_s0  = params(7);     % 7
par.eta_M0        = params(8);     % 8
par.gamma_0    = params(9);     % 9
par.gamma_M   = params(10);    % 10
par.n                  = params(11);    % 11
par.gamma_N    = params(12);    % 12
par.v_N              = params(13);    % 13
par.tau_s           = params(14);    % 14
par.tau_p           = params(15);    % 15
par.tau_m0        = params(16);    % 16
par.tau_n           = par.tau_p + par.tau_m0;
par.Chemo_h_s        = params(17);    % 17
par.Chemo_theta_C = params(18);    % 18
par.Chemo_n3          = params(19);    % 19
par.CSF_v_N_max   = params(20);    % 20
par.CSF_Bn              = params(21);    % 21
par.CSF_gamma_s0_min = params(22);    % 22
par.CSF_eta_M_max        = params(23);    % 23
par.CSF_V_max     = params(24);    % 24
par.CSF_Bs            = params(25);    % 25
par.CSF_Bm           = params(26);    % 26
par.CSF_Bv            = params(27);    % 27
par.BMM_epsilon    = params(28);    % 28
par.BMM_alpha      = params(29);    % 29
par.BMM_theta1     = params(30);    % 30




%% Delay Equation y = [Q; M; N]
Q = y(1,end);
M = y(2,end);
N = y(3,end);
P = y(4,end);


%% Delay
[~,n]=size(y); taus_scale = round(par.tau_s * 10); taun_scale = round(par.tau_n * 10);
Q_tau_s = y(1,n-taus_scale); M_tau_n = y(2,n-taun_scale); Q_tau_n = y(1,n-taun_scale);
P_tau_s  = y(4, n - taus_scale);

%% PD model
if C_cap(th) > 0.01
    if C_csf(th) > 0.01
        Gamma_S = par.CSF_gamma_s0_min + ((par.gamma_s0 + par.Chemo_h_s * C_cap(th)) - par.CSF_gamma_s0_min) * (par.CSF_Bs / (par.CSF_Bs + C_csf(th)));
        Eta_M = par.eta_M0 * P * (par.Chemo_theta_C^par.Chemo_n3/(par.Chemo_theta_C^par.Chemo_n3+C_cap(th)^par.Chemo_n3)) + ...
            (par.CSF_eta_M_max - par.eta_M0 * P * (par.Chemo_theta_C^par.Chemo_n3/(par.Chemo_theta_C^par.Chemo_n3+C_cap(th)^par.Chemo_n3))) * (C_csf(th)/(C_csf(th)+par.CSF_Bm));
        Tau_m = par.tau_m0 / (1+(par.CSF_V_max-1)*(C_csf(th)/(C_csf(th)+par.CSF_Bv)));
        v_N   = par.v_N + (par.CSF_v_N_max - par.v_N) *  (C_csf(th)/(C_csf(th)+par.CSF_Bn));
    else
        Gamma_S = par.gamma_s0 + par.Chemo_h_s * C_cap(th);
        Eta_M = par.eta_M0 * P * (par.Chemo_theta_C^par.Chemo_n3/(par.Chemo_theta_C^par.Chemo_n3+C_cap(th)^par.Chemo_n3));
        Tau_m = par.tau_m0;
          v_N = par.v_N;
    end
else
    if C_csf(th) > 0.01
        Gamma_S = par.CSF_gamma_s0_min + (par.gamma_s0 - par.CSF_gamma_s0_min) * (par.CSF_Bs / (par.CSF_Bs + C_cap(th)));
        Eta_M = par.eta_M0 + (par.CSF_eta_M_max - par.eta_M0) * (C_csf(th)/(C_csf(th)+par.CSF_Bm));
        Tau_m = par.tau_m0 / (1+(par.CSF_V_max-1)*(C_csf(th)/(C_csf(th)+par.CSF_Bv)));
        v_N =par.v_N + (par.CSF_v_N_max - par.v_N) *  (C_csf(th)/(C_csf(th)+par.CSF_Bn));
    else
        Gamma_S = par.gamma_s0;
        Eta_M = par.eta_M0 * P;
        Tau_m = par.tau_m0;
        v_N = par.v_N;
    end
end
%% 
beta = par.beta_0 * P * par.theta_Q.^par.n1./(par.theta_Q.^par.n1 + Q.^par.n1);  
beta_tau_s = par.beta_0 * P_tau_s  * par.theta_Q.^par.n1./(par.theta_Q.^par.n1 + Q_tau_s.^par.n1);

kappa_M = par.kappa_0  * par.theta_M.^par.n2 ./ (par.theta_M.^par.n2 + M.^par.n2);  
kappa_M_tau_n = par.kappa_0  * par.theta_M.^par.n2 ./ (par.theta_M.^par.n2 + M_tau_n.^par.n2);

%% 
Q_out = beta + kappa_M;
Q_in = 2 * exp(-Gamma_S .* par.tau_s) .* beta_tau_s;
M_out =( par.gamma_M + v_N ) ;
M_in = exp(Eta_M .* par.tau_p - par.gamma_0 .* Tau_m) .* kappa_M_tau_n;
N_out = par.gamma_N;
N_in = v_N  ;


P_in =  par.BMM_epsilon .* Q./par.BMM_theta1./(1+Q./par.BMM_theta1).*(1-P);
P_out = par.BMM_alpha .* P; 
%% -------------------- model --------------------
z(1,1) = -Q_out .* Q + Q_in .* Q_tau_s;  
z(2,1) = -M_out .* M +  M_in .* Q_tau_n * 1e-3;  
z(3,1) = - N_out .* N + N_in .* M * 10 ;  
z(4,1) = - P_out + P_in ;

end

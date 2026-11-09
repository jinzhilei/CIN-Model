%% ========================================================================
%  Function: Solve
%
%  Description:
%      Wrapper function to initialize DDE history states and call the
%      explicit Euler DDE solver.
%
%  Inputs:
%      x0           - Initial simulation time
%      h            - Time step size
%      xend         - Terminal simulation time
%      th           - Delay index / delay counter
%      par          - Model parameter vector
%      C_cap        - Capecitabine plasma concentration time series
%      C_csf        - G-CSF concentration time series
%      model_handle - Function handle for DDE right-hand side
%      initial      - Vector of steady-state initial values [Q0, M0, N0, phi]
%
%  Outputs:
%      result_T     - Time vector of simulation results
%      result_Y     - State matrix of simulation results (state × time)
% =========================================================================
function [result_T, result_Y] = Solve(x0, h, xend, th, par, C_cap, C_csf, model_handle, initial)
    % Generate initial delay history matrix
    y0 = initialzation(initial);
    % Call DDE Euler integrator
    [result_T, result_Y] = DDE_Euler(x0, h, xend, y0, th, par, C_cap, C_csf, model_handle);
end

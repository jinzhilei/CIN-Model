%% ========================================================================
%  Function: DDE_Euler
%
%  Description:
%      Explicit Euler integrator for delay differential equations (DDE).
%      This solver maintains the history array for delayed states and
%      calls the user-defined model function at each time step.
%
%  Inputs:
%      x0           - Initial time
%      h            - Time step size
%      xend         - Terminal simulation time
%      y0           - Initial state history matrix (state × time history)
%      th           - Delay index / delay counter
%      par          - Model parameter vector
%      C_cap        - Capecitabine plasma concentration at current time
%      C_csf        - G-CSF concentration at current time
%      model_handle - Function handle for DDE right-hand side
%
%  Outputs:
%      x_out        - Time vector of simulation results
%      y_out        - State matrix of simulation results (state × time)
% =========================================================================
function [x_out, y_out] = DDE_Euler(x0, h, xend, y0, th, par, C_cap, C_csf, model_handle)
    % Initialize output arrays
    x_data = [];
    y_data = [];

    % Assign initial condition
    x_data(1) = x0;
    y_data(:, 1) = y0(:, end);

    % Iteration initialization
    x = x0;
    y = y0;
    [m, n] = size(y0);
    y_old = zeros(m, n-1);
    data_count = 1;

    % Explicit Euler integration loop for DDE
    while x < xend
        k1 = model_handle(x, y, th, par, C_cap, C_csf);
        x = x + h;
        th = th + 1;
        y_old = y(:, 2:n);
        y = y + h * k1;  % Euler method update
        y = horzcat(y_old, y(:, n));

        data_count = data_count + 1;
        x_data(data_count) = x;
        y_data(:, data_count) = y(:, end);
    end

    % Return simulation outputs
    x_out = x_data;
    y_out = y_data;
end

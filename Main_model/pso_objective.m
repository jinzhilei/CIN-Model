%% ========================================================================
%  Function: pso_objective
%
%  Description:
%      Objective function for PSO. Compute sMAPE between simulated neutrophil
%      and experimental observations. Return sMAPE as loss for minimization.
%
%  Inputs:
%      params         - Vector of model parameters to optimize
%      t_start        - Simulation start time (hours)
%      dt_hours       - Time step (hours)
%      t_end          - Simulation terminal time (hours)
%      th             - Time index counter
%      C_cap          - Capecitabine concentration time series
%      C_csf          - G-CSF concentration time series
%      model          - DDE model function handle
%      initial        - Initial steady state vector
%      exp_T          - Experimental observation time points
%      cycle_length   - Treatment cycle length (days)
%      y_obs          - Observed neutrophil data
%
%  Outputs:
%      sMAPE_val      - Symmetric mean absolute percentage error (%)
% =========================================================================
function sMAPE_val = pso_objective(params, t_start, dt_hours, t_end, th, ...
    C_cap, C_csf, model, initial, exp_T, cycle_length, y_obs)
try
    [~, result_Y] = Solve(t_start, dt_hours, t_end, th, params, C_cap, C_csf, model, initial);
catch ME
    % 求解失败直接返回巨大损失，不中断整个PSO
    sMAPE_val = 1e9;
    return;
end

dt_days = dt_hours / 24;                     % Convert time step: hour -> day
day_piont = exp_T + (15 + 1) * cycle_length;  % Experimental time + warm-up offset
index_day = 1 + day_piont ./ dt_days;        % Map time to simulation index

% Clamp index within valid range
index_day = round(index_day);
index_day(index_day < 1) = 1;
index_day(index_day > size(result_Y,2)) = size(result_Y,2);

% Extract predicted neutrophil values
y_pred = result_Y(3, index_day);

% Dimension check
if length(y_pred) ~= length(y_obs)
    warning('Dimension mismatch');
    sMAPE_val = 1e9;
    return;
end

% Remove NaN observations
valid_indices = ~isnan(y_obs);
y_obs = y_obs(valid_indices);
y_pred = y_pred(valid_indices);

% Calculate sMAPE
numerator   = 2 * abs(y_obs - y_pred);
denominator = abs(y_obs) + abs(y_pred);
percentage_terms = numerator ./ denominator;
sMAPE_val = 100 * mean(percentage_terms)
end

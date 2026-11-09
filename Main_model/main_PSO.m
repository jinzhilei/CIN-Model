%% ========================================================================
%  Function: main_PSO
%
%  Description:
%      Particle swarm optimization for hematopoietic DDE model parameter calibration.
%      Perform individual fitting for 30 subjects using observed neutrophil data.
%
%  Inputs:
%
%  Outputs:
%      Optimized parameters and SMAPE value saved into ./PSO/params_*.mat
% =========================================================================
function main_PSO()

    p = PSO_initial();

    % Create output folder
    if ~exist('PSO', 'dir')
        mkdir('PSO');
    end

    n_subjects = 30;
    SwarmSize = 30; % Particle number
    Itercount = 20; % Max PSO iterations
    n_dim = length(p.lb);

    % Preallocate result arrays
    params_all = zeros(n_dim, n_subjects);
    smape_all = zeros(n_subjects, 1);

    % Start parallel pool if necessary
    pool = gcp('nocreate');
    if isempty(pool)
        parpool;
    end

    % Parallel fitting across subjects
    parfor i = 1:n_subjects

        y_obs = p.neutrophil(i,:);
        exp_T = p.exp_data(:,1) % time point

        obj_fun = @(params) pso_objective(params, ...
            p.t_start, p.dt_hours, p.t_end, p.th, ...
            p.C_cap, p.C_csf, p.model, p.initial, ...
            exp_T, p.cycle_length, y_obs);

        % Initialize swarm
        initial_swarm = rand(SwarmSize, n_dim) .* ...
            (p.ub(:)' - p.lb(:)') + p.lb(:)';

        initial_swarm(1,:) = p.param_values(:)';

        % PSO options
        options = optimoptions('particleswarm', ...
            'SwarmSize', SwarmSize, ...
            'MaxIterations', Itercount, ...
            'FunctionTolerance', 1e-6, ...
            'Display', 'iter', ...
            'UseParallel', false, ...
            'InitialSwarmMatrix', initial_swarm);

        % Optimization
        [params_opt, smape_opt] = particleswarm( ...
            obj_fun, n_dim, p.lb(:), p.ub(:), options);

        % Store results in sliced arrays
        params_all(:,i) = params_opt(:);
        smape_all(i) = smape_opt;

    end

    % Save results after parallel computation
    for i = 1:n_subjects
        params_opt = params_all(:,i)';
        smape_opt  = smape_all(i)';

        save_filename = fullfile('PSO', ...
            sprintf('params_%d.mat', i));

        save(save_filename, 'params_opt', 'smape_opt');
    end

    params        = params_all';
    save(fullfile('PSO', 'params.mat'), ...
        'params');

end








function main_Figure_S4B(dataDir, figDir)
% MAIN_FIGURE_S4B  Morris sensitivity analysis (Figure S4B).
%
%   main_Figure_S4B(dataDir, figDir) loads the Morris sensitivity values
%   from mu.mat in dataDir, sorts them in descending order, and renders a
%   bar chart with a red-to-blue gradient. The figure is saved to figDir.
%
%   Inputs:
%       dataDir - folder containing mu.mat (default: 'GSA')
%       figDir  - folder where the figure will be saved (default: 'Figure')
%
%   Example:
%       main_Figure_S4B();
%       main_Figure_S4B('GSA', 'Figure');

    if nargin < 1 || isempty(dataDir)
        dataDir = 'GSA';
    end
    if nargin < 2 || isempty(figDir)
        figDir = 'Figure'; % Standard output directory
    end
    if ~exist(figDir, 'dir')
        mkdir(figDir);
    end

    % ---- Parameter labels (ordered to match the sensitivity values) ----
    param_var = {
        '\beta_0';            % 1
        '\theta_Q';           % 2
        'n_1';                % 3
        '\kappa_0';           % 4
        '\theta_M';           % 5
        'n_2';                % 6
        '\gamma_{s_0}';       % 7
        '\eta_0';             % 8
        '\gamma_0';           % 9
        '\gamma_M';           % 10
        'n';                  % 11
        '\gamma_N';           % 12
        'v_N';                % 13
        '\tau_s';             % 14
        '\tau_p';             % 15
        '\tau_m_0';           % 16
        'h_s';                % 17
        '\theta_C';           % 18
        'n_3';                % 19
        'v_N^{max}';          % 20
        'B_n';                % 21
        '\gamma_{s0}^{min}';  % 22
        '\eta_M^{max}';       % 23
        'V_{max}';            % 24
        'B_s';                % 25
        'B_m';                % 26
        'B_v';                % 27
        '\epsilon';           % 28
        '\alpha';             % 29
        '\theta_1'            % 30
    };

    % ---- Load sensitivity values (Morris method, mu*) ----
    muFile = fullfile(dataDir, 'mu.mat');
    if ~isfile(muFile)
        error('main_Figure_E5B:FileNotFound', ...
              'Sensitivity file not found: %s', muFile);
    end
    S = load(muFile);
    if isfield(S, 'mu')
        mu = S.mu;
    else
        fnames = fieldnames(S);
        if isempty(fnames)
            error('main_Figure_E5B:EmptyFile', ...
                  'No variables found in %s.', muFile);
        end
        mu = S.(fnames{1});
        warning('main_Figure_E5B:VariableName', ...
                'Variable "mu" not found; using "%s" instead.', fnames{1});
    end
    mu = mu(:);

    if numel(mu) ~= numel(param_var)
        error('main_Figure_E5B:SizeMismatch', ...
              'mu has %d entries but %d parameter labels are defined.', ...
              numel(mu), numel(param_var));
    end

    % ---- Sort in descending order (drop zero values first) ----
    idx_nz    = mu ~= 0;
    mu_valid  = mu(idx_nz);
    var_valid = param_var(idx_nz);

    [mu_sorted, ~] = sort(mu_valid, 'descend');
    % var_sorted = var_valid(idx_sort);  % enable if x-tick labels are needed

    % ---- Color gradient: red (231, 76, 60) -> blue (59, 130, 246) ----
    n = numel(mu_sorted);
    colors = [linspace(231, 59, n)', ...
              linspace(76, 130, n)', ...
              linspace(60, 246, n)'] / 255;

    % ---- Plot ----
    fig = figure('Position', [50 50 1400 1000], 'Color', 'w');
    subplot(2, 4, [1, 2, 3]);
    hold on;

    b = bar(mu_sorted, 0.7);

    for i = 1:n
        b.CData(i, :) = colors(i, :);
    end
    b.FaceColor = 'flat';
    b.EdgeColor = 'k';
    b.LineWidth = 1;

    ylabel('Sensitivity (\mu^*)', 'FontSize', 13);
    set(gca, 'FontSize', 20, 'LineWidth', 1.5);
    grid on;
    set(gca, 'XTickLabel', []);
    box on;
    ylim([0, max(mu_sorted) * 1.1]);

    hold off;

    % ---- Export Figure ----
    outFile = fullfile(figDir, 'Figure_S4B.png');
    exportgraphics(fig, outFile, 'Resolution', 300);
    fprintf('Saved: %s\n', outFile);
end
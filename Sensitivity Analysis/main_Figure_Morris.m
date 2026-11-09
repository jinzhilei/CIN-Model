function main_Figure_Morris(outputDir)
% MAIN_FIGURE_MORRIS Generate a bar chart for Morris sensitivity analysis.
%   main_Figure_Morris() saves the figure as a 300 dpi PNG in 'Figure' directory.
%   main_Figure_Morris(outputDir) saves the figure in the specified directory.

    % Handle input arguments for output directory
    if nargin < 1
        outputDir = 'Figure';
    end

    %% Load sensitivity data
    load(['output/mu.mat'])

    % Parameter labels (ordered to match the sensitivity values)
    param_var = {
        '\beta_0';         % 1
        '\theta_Q';        % 2
        'n_1';             % 3
        '\kappa_0';        % 4
        '\theta_M';        % 5
        'n_2';             % 6
        '\gamma_s';        % 7
        '\eta_0';          % 8
        '\gamma_0';        % 9
        '\gamma_M';        % 10
        'n';               % 11
        '\gamma_N';        % 12
        'v_N';             % 13
        '\tau_s';          % 14
        '\tau_p';          % 15
        '\tau_m';          % 16
        'h_s';             % 17
        '\theta_C';        % 18
        'n_3';             % 19
        'v_N^{max}';       % 20
        'B_n';             % 21
        '\gamma_{s0}^{min}'; % 22
        '\eta_M^{max}';    % 23
        'V_{max}';         % 24
        'B_s';             % 25
        'B_m';             % 26
        'B_v';             % 27
        '\epsilon';        % 28
        '\alpha';          % 29
        '\theta_1'         % 30
    };

    %% ===================== Sort (descending) =====================
    mu = mu(:);                 % ensure column vector
    idx_nz = mu ~= 0;           % remove zero values
    mu_valid = mu(idx_nz);
    var_valid = param_var(idx_nz);

    % Sort in descending order
    [mu_sorted, idx_sort] = sort(mu_valid, 'descend');
    var_sorted = var_valid(idx_sort);

    %% ===================== Color gradient: red -> blue =====================
    n = length(mu_sorted);      % use actual number of valid entries
    colors = [linspace(231, 59, n)', ...
              linspace(76, 130, n)', ...
              linspace(60, 246, n)'] / 255;

    %% ===================== Plot =====================
    fig = figure('Position', [50 50 1400 1000]);
    subplot(2, 4, [1, 2, 3])
    hold on;

    b = bar(mu_sorted, 0.7);

    % Assign individual bar colors
    for i = 1:n
        b.CData(i, :) = colors(i, :);
    end
    b.FaceColor = 'flat';
    b.EdgeColor = 'k';
    b.LineWidth = 1;

    % Axis settings
    set(gca, ...
        'XTick',      1:n, ...
        'XTickLabel', var_sorted, ...
        'TickLabelInterpreter', 'tex', ...   % render LaTeX symbols correctly
        'FontSize',   10, ...                % adjusted size for x-axis labels
        'FontName',   'Times New Roman');

    xtickangle(45);   % rotate x labels 45 degrees to prevent overlap
    
    % Labels (set to Times New Roman)
    ylabel('Sensitivity (\mu*)', 'FontSize', 13, 'FontName', 'Times New Roman');
    
    % Set global axes font
    set(gca, 'FontSize', 16, 'LineWidth', 1.5, 'FontName', 'Times New Roman');
    grid on;
    box on;
    ylim([0, max(mu_sorted) * 1.1]);
    hold off;

    % -------- Save Figure --------
    if ~isempty(outputDir)
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        outFile = fullfile(outputDir, 'Figure_Morris.png');
        exportgraphics(fig, outFile, 'Resolution', 300);
        fprintf('Saved: %s\n', outFile);
    end
end
%% ========================================================================
%  Function: main_Figure_5D
%
%  Description:
%      Boxplots with superimposed scatter points for 12 fitted parameters.
%      Comparison between Severe and Moderate neutropenia groups.
%      Mann–Whitney U test (ranksum) for between-group comparison.
%
%  Input:
%      params.mat: matrix [n_subject × n_param], optimized parameters from PSO
%
%  Output:
%      Figure: 2×6 subplot boxplots with individual data points and p-values
% =========================================================================
function main_Figure_5D(outputDir)
    % Handle input arguments for output directory
    if nargin < 1
        outputDir = 'Figure';
    end

    %% Load parameter matrix
    load('params.mat');

    %% Parameter labels (LaTeX for journal)
    param_names = {
        '$\beta_0$',                 % 1
        '$\theta_Q$',                % 2
        '$\theta_M$',                % 3
        '$\gamma_N$',                % 4
        '$\theta_C$',                % 5
        '$h_s$',                     % 6
        '$\eta_{M}^{\mathrm{max}}$', % 7
        '$B_s$',                     % 8
        '$B_n$',                     % 9
        '$\epsilon$',                %10
        '$\alpha$',                  %11
        '$\theta_1$'                %12
    };

    %% Group definition
    rows_group1 = [1,2,3,5,7,8,12,13,19,22,24,25,30];  % Severe
    all_rows    = 1:30;
    rows_group2 = setdiff(all_rows, rows_group1);        % Moderate

    group1 = params(rows_group1, :);
    group2 = params(rows_group2, :);

    %% Figure setting (journal style)
    fig = figure('Position', [50, 50, 1500, 330]);
    set(fig, 'Units', 'Normalized', 'Position', [0.05, 0.1, 0.95, 0.45]);

    %% Color scheme
    mycolor = [0.0000 0.4470 0.7410;   % Severe: blue
               0.8500 0.3250 0.0980];  % Moderate: orange
    scatter_color = mycolor;

    %% Subplot loop for each parameter
    for col = 1:12
        subplot(2, 6, col);
        data1 = group1(:, col);
        data2 = group2(:, col);
        all_data = [data1; data2];
        group_label = [ones(length(data1),1); 2*ones(length(data2),1)];

        %% Mann–Whitney U test
        [p, ~] = ranksum(data1, data2);

        %% Boxplot
        bp = boxplot(all_data, group_label, ...
            'Labels', {'Severe','Moderate'}, ...
            'Widths', 0.6, ...
            'Colors', 'k', ...
            'Symbol', 'o', ...
            'OutlierSize', 4, ...
            'Whisker', 1.5, ...
            'BoxStyle', 'outline');

        %% Fill box with color
        boxobj = findobj(gca,'Tag','Box');
        for i = 1:2
            patch(get(boxobj(i),'XData'),get(boxobj(i),'YData'),mycolor(i,:),...
                'FaceAlpha',0.5,'LineWidth',1.1);
        end

        %% Line style
        box_line = findobj(gca, 'Type', 'line');
        set(box_line, 'LineWidth', 1.5);
        set(gca, 'Box', 'on');
        set(gca, 'LineWidth', 1.5);
        grid off;

        %% Font setting (Arial, journal standard)
        set(gca, 'FontSize', 14, 'FontName', 'Arial');
        xlabel('');
        hold on;

        %% Scatter individual points (jitter)
        for i = 1:2
            data = all_data(group_label == i);
            x = i * ones(size(data)) + (rand(size(data))-0.5)*0.2;
            scatter(x, data, 60, scatter_color(i,:), 'filled', ...
                'MarkerEdgeColor', 'white', 'LineWidth', 2);
        end

        %% Significance bar and p-value
        y_max = max(all_data);
        y_line = y_max * 1.15;
        y_text = y_max * 1.25;
        plot([1, 2], [y_line, y_line], 'k', 'LineWidth', 1);
        plot([1, 1], [y_line, y_line*0.95], 'k', 'LineWidth', 1);
        plot([2, 2], [y_line, y_line*0.95], 'k', 'LineWidth', 1);

        text(1.5, y_text, sprintf('$p = %.3f$', p), ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 12, 'FontName', 'Arial', 'Interpreter','latex');

        %% Axis limit
        y_min = min(all_data);
        ylim([y_min * 0.8, y_max * 1.35]);
        title(param_names{col}, 'Interpreter','latex','FontSize',15,'FontName','Arial');
        hold off;
    end

    % -------- Save Figure --------
    if ~isempty(outputDir)
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        outFile = fullfile(outputDir, 'Figure_5D.png');
        exportgraphics(fig, outFile, 'Resolution', 300);
        fprintf('Saved: %s\n', outFile);
    end

end

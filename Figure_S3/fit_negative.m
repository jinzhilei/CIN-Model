%% ========================================================================
%  Function: fit_negative()
%
%  Description:
%      Linear regression scatter plots with 95% confidence band for selected
%      parameter pairs. Display Pearson correlation p-value on each subplot.
%
%  Input:
%      patient_12parameters.csv  - Table of fitted model parameters
%
%  Output:
%      Figure: subplots of pairwise linear correlations
% =========================================================================
function fit_negative()

    %% Load parameter table
   tbl = readtable('patient_12parameters.csv'); 
   tbl = tbl(1:end, 2:end);   % row names and column names removed
 
    %% Define column pairs to correlate [x_col, y_col]
    pairs = [2, 10;   % e.g. parameter #2 vs #10
             3, 4;    % e.g. parameter #3 vs #4
             3, 9];   % e.g. parameter #3 vs #9

    %% Loop over correlation pairs
    for i = 1:size(pairs, 1)
        subplot(3, 4, i + 8);

        x = tbl{:, pairs(i,1)};
        y = tbl{:, pairs(i,2)};

        % Remove NaN pairs
        idx = ~isnan(x) & ~isnan(y);
        x = x(idx);
        y = y(idx);

        % Linear fit y = k*x + b
        [p, s] = polyfit(x, y, 1);
        k = p(1);
        b = p(2);

        % Fitted line
        x_line = linspace(min(x), max(x), 100);
        y_line = polyval(p, x_line);

        % Pearson correlation and p-value
        [r, pval] = corr(x, y);
        R2 = r^2;

        % 95% confidence band
        [yfit, dy] = polyconf(p, x_line, s, 'predopt', 'curve');

        hold on;
        % Confidence region
        fill([x_line, fliplr(x_line)], ...
            [yfit - dy, fliplr(yfit + dy)], ...
            [0, 191, 255]./255, 'FaceAlpha', 0.2);

        % Data scatter
        scatter(x, y, 150, [0.2, 0.55, 0.75], 'filled', ...
            'MarkerEdgeColor', 'w', 'LineWidth', 1);

        % Regression line
        plot(x_line, y_line, 'LineWidth', 4, 'Color', [0, 114, 178]./255);

        % p-value annotation
        text(max(x) - 0.35*range(x), max(y) - 0.1*range(y), ...
            sprintf('$p=%.3f$', pval), ...
            'FontSize', 16, 'FontName', 'Arial', 'Interpreter','latex', ...
            'BackgroundColor', 'w');

        xlim([min(x), max(x)]);
        set(gca, 'FontSize', 20, 'FontName', 'Arial', ...
            'Box', 'on', 'LineWidth', 1.5);
        grid on;
        hold off;
    end
end

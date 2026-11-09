%% ========================================================================
%  Function: fit_positive()
%
%  Description:
%      Linear regression scatter plots with 95% confidence band for positively
%      correlated parameter pairs. Pearson correlation p-value annotated in each subplot.
%
%  Input:
%      patient_12parameters.csv  - Table of fitted model parameters
%
%  Output:
%      Figure: subplots of pairwise positive linear correlations
% =========================================================================
function fit_positive()

    %% Load parameter table
    tbl = readtable('patient_12parameters.csv');
    tbl(:, 1) = [];   % row names and column names removed

    %% Define positively correlated parameter pairs [x_col, y_col]
    pos_pairs = [1, 12;
                 3, 8;
                 4, 5;
                 4, 6;
                 4, 7;
                 4,10;
                 6, 7;
                 6,10];

    %% Create figure canvas
    figure('Color','w','Position',[50,50,1400,1000]);

    %% Loop over positive correlation pairs
    for i = 1:size(pos_pairs,1)
        subplot(3,4,i);

        x = tbl{:, pos_pairs(i,1)};
        y = tbl{:, pos_pairs(i,2)};

        % Remove paired NaN
        idx = ~isnan(x) & ~isnan(y);
        x = x(idx);
        y = y(idx);

        % Linear fit y = k*x + b
        [p, s] = polyfit(x, y, 1);
        k = p(1);
        b = p(2);

        x_line = linspace(min(x), max(x), 100);
        y_line = polyval(p, x_line);

        % Pearson correlation
        [r, pval] = corr(x, y);
        R2 = r^2;

        % 95% confidence band
        [yfit, dy] = polyconf(p, x_line, s, 'predopt', 'curve');

        hold on;
        % Confidence region fill
        fill([x_line, fliplr(x_line)], ...
            [yfit - dy, fliplr(yfit + dy)], ...
            [233, 30, 99]./255, 'FaceAlpha', 0.2);

        % Scatter points
        scatter(x, y, 150, [233, 30, 99]./255, 'filled', ...
            'MarkerEdgeColor','w','LineWidth',1);

        % Regression line
        plot(x_line, y_line, 'LineWidth',4, 'Color', [233, 30, 99]./255);

        % Annotate p-value with LaTeX interpreter
        text(max(x)-0.35*range(x), max(y)-0.1*range(y), ...
            sprintf('$p=%.3f$', pval), ...
            'FontSize',16,'FontName','Arial','Interpreter','latex','BackgroundColor','w');

        xlim([min(x), max(x)]);
        set(gca,'FontSize',20,'FontName','Arial','Box','on','LineWidth',1.5);
        grid on;
        hold off;
    end
end

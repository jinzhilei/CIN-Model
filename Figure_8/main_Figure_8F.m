function main_Figure_8F(statsFile, outputDir)
%   main_Figure_8F  Plot a 2x2 panel of grouped statistics heatmaps.
%
%   plot_grouped_heatmaps(statsFile, outputDir) loads the grouped statistics
%   matrices from statsFile, renders a 2x2 heatmap panel (ANC/Duration x
%   Severe/Moderate), and saves the figure to outputDir.
%
%   Inputs:
%       statsFile - path to 'Grouped_Stats_Matrices.mat'
%

    if nargin < 1 || isempty(statsFile)
        statsFile = fullfile('Result', 'Grouped_Stats_Matrices.mat');
    end
    if nargin < 2 || isempty(outputDir)
        outputDir = 'Figure'; % Standard output directory
    end
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    S = load(statsFile);
    required = {'ANC_Severe_Mat', 'ANC_Moderate_Mat', ...
                'Dur_Severe_Mat', 'Dur_Moderate_Mat'};
    for k = 1:numel(required)
        if ~isfield(S, required{k})
            error('plot_grouped_heatmaps:MissingVariable', ...
                  'Variable "%s" not found in %s.', required{k}, statsFile);
        end
    end

    % Custom colormap: dark blue -> light blue -> white -> yellow -> red
    C = [0.10  0.10  0.50;
         0.15  0.30  0.65;
         0.20  0.50  0.80;
         0.30  0.65  0.85;
         0.50  0.80  0.90;
         0.75  0.90  0.95;
         1.00  1.00  1.00;
         1.00  0.90  0.60;
         0.90  0.90  0.60;
         1.00  0.60  0.30;
         0.80  0.10  0.10;
         0.50  0.00  0.00];
    mycmap = interp1(linspace(0, 1, size(C, 1)), C, linspace(0, 1, 256));

    plot_data = {S.ANC_Severe_Mat, S.ANC_Moderate_Mat, ...
                 S.Dur_Severe_Mat, S.Dur_Moderate_Mat};
    plot_titles = {'ANC - Severe', 'ANC - Moderate', ...
                   'Duration - Severe', 'Duration - Moderate'};

    x_labels = {'n=1', 'n=2', 'n=4'};
    y_labels = {'\tau=1', '\tau=2', '\tau=3'};

    fig = figure('Color', 'w', 'Position', [100 100 800 500]);

    for i = 1:4
        subplot(2, 2, i);
        current_matrix = plot_data{i};

        imagesc(current_matrix);
        set(gca, 'YDir', 'reverse');
        colormap(mycmap);
        colorbar;
        clim([min(current_matrix(:)) max(current_matrix(:))]);

        title(plot_titles{i}, 'FontSize', 15, 'FontWeight', 'bold');
        xlabel('Total injections (n)', 'FontSize', 12);
        ylabel('Interval (\tau)', 'FontSize', 12);

        xticks(1:3); yticks(1:3);
        xticklabels(x_labels);
        yticklabels(y_labels);

        set(gca, 'FontSize', 12, 'LineWidth', 1.5, 'TickLength', [0 0]);

        hold on;
        for x = 0.5:1:3.5
            plot([x x], [0.5 3.5], 'k-', 'LineWidth', 1.5);
        end
        for y = 0.5:1:3.5
            plot([0.5 3.5], [y y], 'k-', 'LineWidth', 1.5);
        end
        hold off;
    end

    % -------- Save Figure --------
    if ~isempty(outputDir)
        outFile = fullfile(outputDir, 'Figure_8F.png');
        exportgraphics(fig, outFile, 'Resolution', 300);
        fprintf('Saved: %s\n', outFile);
    end

end
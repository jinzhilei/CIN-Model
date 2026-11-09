function main_Figure_S6(outputDir)
    % Main function to generate Figure S6 (Scatter plots for T1, T2, and T3)

    % Handle input arguments for output directory
    if nargin < 1
        outputDir = 'Figure';
    end
    
    clc;
    
    % 1. Load data
    try
        load('ANCtrue.mat');
        load('ANC.mat');
    catch
        error('Ensure ANCtrue.mat and ANC.mat are in the current working directory.');
    end
    
    % 2. Define groups
    rows_group1 = [1,2,3,5,7,8,12,13,19,22,24,25,30]; % Severe
    rows_group2 = setdiff(1:30, rows_group1);          % Moderate
    
    % 3. Initialize figure
    fig = figure('Position',[50 50 1400 1000]);
    
    % 4. Loop to plot T1, T2, and T3
    % ANC column layout: T1(cols 1,2), T2(cols 3,4), T3(cols 5,6)
    col_indices = [1, 2; 3, 4; 5, 6]; 
    time_labels = {'T1', 'T2', 'T3'};
    
    for i = 1:3
        subplot(2, 3, i);
        hold on;
        
        % Extract data for current time point
        x_data = ANC(:, col_indices(i, 1));
        y_data = ANC(:, col_indices(i, 2));
        
        % Plot scatter for Group 2 (Blue)
        scatter(x_data(rows_group2), y_data(rows_group2), 100, 'filled', 'o', ...
            'MarkerFaceColor', [0.2 0.4 0.8], 'DisplayName', 'Group 2');
            
        % Plot scatter for Group 1 (Red)
        scatter(x_data(rows_group1), y_data(rows_group1), 100, 'filled', 'o', ...
            'MarkerFaceColor', [0.8 0.2 0.2], 'DisplayName', 'Group 1');
        
        % Set title
        title(time_labels{i}, 'FontSize', 16);
        % Set axes properties
        ax = gca;  
        set(ax, 'YScale', 'log');
        xlim(ax, [0.2, 2.5]);         
        ylim(ax, [1, 20]);
        
        % Add labels (Y-label only for the first plot to avoid redundancy)
        if i == 1
            ylabel('High value', 'FontSize', 14);
        end
        xlabel('Low value', 'FontSize', 14);
        
        % Formatting
        set(ax, 'LineWidth', 2); 
        set(ax, 'FontSize', 16); 
        box on;
        grid off;
        ax.TickLength = [0.02, 0.01]; 
        
        % Add legend only to the first plot
        if i == 1
            legend('Severe','Moderate','Location', 'best', 'FontSize', 14);
            legend box off
        end
        
        hold off;
    end

    % -------- Save Figure --------
    if ~isempty(outputDir)
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        outFile = fullfile(outputDir, 'Figure_S6.png');
        exportgraphics(fig, outFile, 'Resolution', 300);
        fprintf('Saved: %s\n', outFile);
    end
end

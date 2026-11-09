%==========================================================================
% Function: main_Figure_5A
% Purpose: Grouped bar plot with error bars (mean ± standard deviation)
%          for circulating neutrophil counts at predefined time points.
%          Patients are split into Severe and Moderate groups.
% Data file required: Data_neutrophil.mat
%==========================================================================
function main_Figure_5A(outputDir)
    % Handle input arguments for output directory
    if nargin < 1
        outputDir = 'Figure';
    end

    % Load experimental neutrophil data
    load('Data_neutrophil.mat')
    neutrophil = Data_neutrophil./1.4; % Convert: 5L total blood volume, 70 kg body weight

    % Patient index grouping
    rows_group1 = [1,2,3,5,7,8,12,13,19,22,24,25,30];
    rows_group2 = setdiff(1:30, rows_group1);
    all_patients = 1:30;

    % Predefined observation time points
    T_indices = [0, 4, 21, 25, 42, 46];
    n_time = length(T_indices);

    % Preallocate arrays for mean and standard deviation
    mean_vals_group1 = zeros(1, n_time);
    mean_vals_group2 = zeros(1, n_time);
    std_vals_group1  = zeros(1, n_time);
    std_vals_group2  = zeros(1, n_time);
    data_group1      = [];
    data_group2      = [];

    for col = 1:n_time
        % Group1: Severe
        current_col1 = neutrophil(rows_group1, col);
        data_group1(:,col) = current_col1;
        valid_data1 = current_col1(~isnan(current_col1));
        mean_vals_group1(col) = mean(valid_data1);
        std_vals_group1(col)  = std(valid_data1);

        % Group2: Moderate
        current_col2 = neutrophil(rows_group2, col);
        data_group2(:,col) = current_col2;
        valid_data2 = current_col2(~isnan(current_col2));
        mean_vals_group2(col) = mean(valid_data2);
        std_vals_group2(col)  = std(valid_data2);
    end

    % Plot grouped bar chart with error bars (mean ± SD)
    fig = figure('Position',[50 50 1400 1000]);
    subplot(2,4,[1,2])
    hold on; grid on;
    width = 0.35;
    x = 1:n_time;
    
    bar1 = bar(x - width/2, mean_vals_group1, width, 'FaceColor', [0.85 0.33 0.10], 'EdgeColor', 'k', 'LineWidth', 1.2);
    bar2 = bar(x + width/2, mean_vals_group2, width, 'FaceColor', [0.0 0.45 0.74], 'EdgeColor', 'k', 'LineWidth', 1.2);

    % Error bar without connecting line
    errorbar(x - width/2, mean_vals_group1, std_vals_group1, 'k','Linestyle','none', 'LineWidth', 1.5, 'CapSize', 6);
    errorbar(x + width/2, mean_vals_group2, std_vals_group2, 'k','Linestyle','none', 'LineWidth', 1.5, 'CapSize', 6);

    % Axis settings
    set(gca, 'XTick', x, 'XTickLabel', T_indices, 'FontSize', 22, 'FontName', 'Arial');
    xlabel('Time (days)', 'FontSize', 22);
    ylabel('Neutrophil count', 'FontSize', 22);
    legend('Severe', 'Moderate', 'Location', 'best', 'FontSize', 16);
    set(gca, 'LineWidth', 1.5);
    box on
    legend box off
    ylim([0, max([mean_vals_group1 + std_vals_group1, mean_vals_group2 + std_vals_group2]) * 1.3]);
    hold off;

    % -------- Save Figure --------
    if ~isempty(outputDir)
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        outFile = fullfile(outputDir, 'Figure_5A.png');
        exportgraphics(fig, outFile, 'Resolution', 300);
        fprintf('Saved: %s\n', outFile);
    end
end

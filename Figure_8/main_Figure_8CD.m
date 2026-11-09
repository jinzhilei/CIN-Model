%==========================================================================
% Function: main_Figure_8CD
% Purpose: Generate paired line plots for Figure 8C and 8D
%          8C: Duration of neutropenia; 8D: Nadir ANC value
%          Paired comparison between T1 and T3 for Severe / Mild groups
% Input:  None
% Output: None
%==========================================================================
function main_Figure_8CD(outputDir)

    % Handle input arguments for output directory
    if nargin < 1
        outputDir = 'Figure';
    end

    load('Data_AB/Durations.mat')
    load('Data_AB/Nadir.mat')
    
    %% Group definition
    rows_group1 = [1,2,3,5,7,8,12,13,19,22,24,25,30];  % Severe
    all_rows    = 1:30;
    rows_group2 = setdiff(all_rows, rows_group1);        % Moderate

    % Raw data [T1, T3]
    dur1_severe   = durations(rows_group1, 1);   % 13x1
    dur1_moderate = durations(rows_group2, 1);   % 17x1
    dur3_severe   = durations(rows_group1, 3);
    dur3_moderate = durations(rows_group2, 3);
    
    % ----average---
    mean1_severe   = mean(dur1_severe,   'omitnan');   % scalar
    mean1_moderate = mean(dur1_moderate, 'omitnan');   % scalar
    mean3_severe   = mean(dur3_severe,   'omitnan');   % scalar
    mean3_moderate = mean(dur3_moderate, 'omitnan');   % scalar

    % ---- Extract period 1 ----
    nadir1_severe   = nadir(rows_group1, 1);   % 13x1
    nadir1_moderate = nadir(rows_group2, 1);   % 17x1
    % ---- Extract period 3 ----
    nadir3_severe   = nadir(rows_group1, 3);   % 13x1
    nadir3_moderate = nadir(rows_group2, 3);   % 17x1

    % ---- average ----
    meanN1_severe   = mean(nadir1_severe,   'omitnan');   % scalar
    meanN1_moderate = mean(nadir1_moderate, 'omitnan');   % scalar
    meanN3_severe   = mean(nadir3_severe,   'omitnan');   % scalar
    meanN3_moderate = mean(nadir3_moderate, 'omitnan');   % scalar

    data = [
        mean1_severe	mean3_severe       % duration-Severe
        mean1_moderate	mean3_moderate     % duration-Mild
        meanN1_severe   meanN3_severe      % nadir-Severe
        meanN1_moderate meanN3_moderate    % nadir-Mild
    ];

    % Index grouping
    group1 = 1:2;   % Duration (for 8C)
    group2 = 3:4;   % Nadir ANC (for 8D)

    % Create figure window
    fig = figure('Color','white','Position',[50 50 1500 1000]);

    %% Subplot 8C: Duration
    subplot(4,3,[1,4]);
    hold on;
    for i = group1
        plot([1,2], [data(i,1), data(i,2)], 'Color',[0.7 0.7 0.7],'LineWidth',2);
        scatter(1, data(i,1), 120, 'w','filled','MarkerEdgeColor','k'); % T1 white fill, black edge
        if i == group1(1)
            scatter(2, data(i,2), 120, [0.8 0 0], 'filled');   % first: red
        else
            scatter(2, data(i,2), 120, [0 0.4470 0.7410], 'filled');   % second: blue
        end
    end
    title('Duration','FontSize',14);
    xticks([1 2]);
    xticklabels({'T1','T3'});
    xlim([0.7, 2.3]);
    ylim([8,16]);
    ylabel('Day','FontSize',12);
    grid off;
    set(gca,'FontSize',20);
    set(gca, 'LineWidth', 2);
    box on;
    ax = gca;
    ax.TickLength = [0.02, 0.01];
    hold off;

    %% Subplot 8D: Nadir
    subplot(4,3,[2,5]);
    hold on;
    for i = group2
        plot([1,2], [data(i,1), data(i,2)], 'Color',[0.7 0.7 0.7],'LineWidth',2);
        scatter(1, data(i,1), 120, 'w','filled','MarkerEdgeColor','k');
        if i == group2(1)
            scatter(2, data(i,2), 120, [0.8 0 0], 'filled');   % first: red
        else
            scatter(2, data(i,2), 120, [0 0.4470 0.7410], 'filled');   % second: blue
        end
    end
    title('Nadir','FontSize',14);
    xticks([1 2]);
    xticklabels({'T1','T3'});
    xlim([0.7, 2.3]);
    ylim([0.2,0.5]);
    ylabel('ANC','FontSize',12);
    grid off;
    set(gca,'FontSize',20);
    set(gca, 'LineWidth', 2);
    box on;
    ax = gca;
    ax.TickLength = [0.02, 0.01];
    hold off;

    % -------- Save Figure --------
    if ~isempty(outputDir)
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        outFile = fullfile(outputDir, 'Figure_8CD.png');
        exportgraphics(fig, outFile, 'Resolution', 300);
        fprintf('Saved: %s\n', outFile);
    end

end
%==========================================================================
% Function: main_Figure_8AB
% Purpose: Generate ridge plots (kernel density ridge chart) for two subplots
%          Subplot 8A: Neutropenia duration distribution (Durations.mat)
%          Subplot 8B: Minimum ANC value distribution (Nadir.mat)
% Input:  None
% Output: None
% Required data: Data_AB/Durations.mat, Data_AB/Nadir.mat
%==========================================================================
function main_Figure_8AB(outputDir)

    % Handle input arguments for output directory
    if nargin < 1
        outputDir = 'Figure';
    end

    %% ===================== Subplot 8A: Durations ridge plot =====================
    load('Data_AB/Durations.mat');
    % Extract data and remove NaN
    data1 = durations(:,1); data1 = data1(~isnan(data1));
    data2 = durations(:,2); data2 = data2(~isnan(data2));
    data3 = durations(:,3); data3 = data3(~isnan(data3));

    % Kernel density estimation
    x = linspace(0, 21, 500);
    [f1, xi1] = ksdensity(data1, x);
    [f2, xi2] = ksdensity(data2, x);
    [f3, xi3] = ksdensity(data3, x);

    % Ridge vertical offset
    bottom_gap = 0.05;
    gap = 0.15;
    f1_shift = f1 + bottom_gap;
    f2_shift = f2 + gap + bottom_gap;
    f3_shift = f3 + gap*2 + bottom_gap;

    % Color definition
    color_1 = [254,235,231]./255;
    color_2 = [249,159,174]./255;
    color_3 = [244,63,94]./255;

    % Create figure
    fig = figure('Color','white','Position',[50 50 1500 1000]);
    subplot(5,3,[1,4]);
    hold on;
    % Fill & plot ridge layers
    fill([xi3, fliplr(xi3)], [(gap*2+bottom_gap)*ones(size(f3_shift)), fliplr(f3_shift)],...
        color_3, 'FaceAlpha',0.8, 'EdgeColor','none');
    plot(xi3, f3_shift, 'Color','k', 'LineWidth',2.5);

    fill([xi2, fliplr(xi2)], [(gap+bottom_gap)*ones(size(f2_shift)), fliplr(f2_shift)],...
        color_2, 'FaceAlpha',0.8, 'EdgeColor','none');
    plot(xi2, f2_shift, 'Color','k', 'LineWidth',2.5);

    fill([xi1, fliplr(xi1)], [bottom_gap*ones(size(f1_shift)), fliplr(f1_shift)],...
        color_1, 'FaceAlpha',0.8, 'EdgeColor','none');
    plot(xi1, f1_shift, 'Color','k', 'LineWidth',2.5);

    % Vertical dashed line at density peak
    [~, idx1] = max(f1); x1 = xi1(idx1);
    plot([x1,x1], [bottom_gap, f1_shift(idx1)], 'k--','LineWidth',1);

    [~, idx2] = max(f2); x2 = xi2(idx2);
    plot([x2,x2], [bottom_gap+gap, f2_shift(idx2)], 'k--','LineWidth',1);

    [~, idx3] = max(f3); x3 = xi3(idx3);
    plot([x3,x3], [bottom_gap+gap*2, f3_shift(idx3)], 'k--','LineWidth',1);

    % Axis settings
    xlim([0,21]);
    xlabel('Time (days)', 'FontSize',22);
    set(gca, 'YTickLabel', [])
    ylim([0,0.5]);
    yticks([0.05,0.2,0.35])
    yticklabels({'T1','T2','T3'})
    set(gca,'LineWidth',1.5,'FontSize',22);
    box on
    hold off;

    %% ===================== Subplot 8B: Min ANC ridge plot =====================
    load('Data_AB/Nadir.mat');
    data1 = nadir(:,1); data1 = data1(~isnan(data1));
    data2 = nadir(:,2); data2 = data2(~isnan(data2));
    data3 = nadir(:,3); data3 = data3(~isnan(data3));

    % Kernel density estimation
    x = linspace(0, 1, 500);
    [f1, xi1] = ksdensity(data1, x);
    [f2, xi2] = ksdensity(data2, x);
    [f3, xi3] = ksdensity(data3, x);

    % Ridge vertical offset
    bottom_gap = 0.5;
    gap = 2;
    f1_shift = f1 + bottom_gap;
    f2_shift = f2 + gap + bottom_gap;
    f3_shift = f3 + gap*2 + bottom_gap;

    % Same color palette
    color_1 = [254,235,231]./255;
    color_2 = [249,159,174]./255;
    color_3 = [244,63,94]./255;

    subplot(5,3,[2,5]);
    hold on;
    fill([xi3, fliplr(xi3)], [(gap*2+bottom_gap)*ones(size(f3_shift)), fliplr(f3_shift)],...
        color_3, 'FaceAlpha',0.8, 'EdgeColor','none');
    plot(xi3, f3_shift, 'Color','k', 'LineWidth',2.5);

    fill([xi2, fliplr(xi2)], [(gap+bottom_gap)*ones(size(f2_shift)), fliplr(f2_shift)],...
        color_2, 'FaceAlpha',0.8, 'EdgeColor','none');
    plot(xi2, f2_shift, 'Color','k', 'LineWidth',2.5);

    fill([xi1, fliplr(xi1)], [bottom_gap*ones(size(f1_shift)), fliplr(f1_shift)],...
        color_1, 'FaceAlpha',0.8, 'EdgeColor','none');
    plot(xi1, f1_shift, 'Color','k', 'LineWidth',2.5);

    % Peak vertical dashed line
    [~, idx1] = max(f1); x1 = xi1(idx1);
    plot([x1,x1], [bottom_gap, f1_shift(idx1)], 'k--','LineWidth',1);

    [~, idx2] = max(f2); x2 = xi2(idx2);
    plot([x2,x2], [bottom_gap+gap, f2_shift(idx2)], 'k--','LineWidth',1);

    [~, idx3] = max(f3(1:300)); x3 = xi3(idx3);
    plot([x3,x3], [bottom_gap+gap*2, f3_shift(idx3)], 'k--','LineWidth',1);

    % Axis settings
    xlim([0,1]);
    xlabel('ANC (\times10^8 cells/kg)', 'FontSize',22);
    set(gca, 'YTickLabel', [])
    ylim([0,8.5]);
    yticks([0.5,2.5,4.5])
    yticklabels({'T1','T2','T3'})
    set(gca,'LineWidth',1.5,'FontSize',22);
    box on
    hold off;

    % -------- Save Figure --------
    if ~isempty(outputDir)
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        outFile = fullfile(outputDir, 'Figure_8AB.png');
        exportgraphics(fig, outFile, 'Resolution', 300);
        fprintf('Saved: %s\n', outFile);
    end

end



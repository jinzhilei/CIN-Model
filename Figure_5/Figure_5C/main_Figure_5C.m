function main_Figure_5C(outputDir)
%==========================================================================
% main_Figure_5C
% Figure 5C: Boxplot with jittered scatter points comparing the duration
% of grade 2 neutropenia between Severe (n=13) and Moderate (n=17) groups.
% Statistical test: Mann-Whitney U test (ranksum).
%
% Required data file: Durations.mat (variable: durations)
% Required toolbox: Statistics and Machine Learning Toolbox (ranksum)
%
% Reproducibility: random seed fixed for jittered scatter points.
%==========================================================================

% Handle input arguments for output directory
if nargin < 1
    outputDir = 'Figure';
end

rng(111)  % fixed seed for reproducible jitter

%--------------------------------------------------------------------------
% 1. Data loading and grouping
%--------------------------------------------------------------------------
load('duration_n1_taut1.mat')
data = sum(durations_n1_tau1, 2);

% group_idx: 1 = Severe, 2 = Moderate
group_idx = [1,1,1,2,1,2,1,1,2,2,2,1,1,2,2,2,2,2,1,2,2,1,2,1,1,2,2,2,2,1];
Severe   = data(group_idx == 1);   % n = 13
Moderate = data(group_idx == 2);   % n = 17

all_data    = [Severe; Moderate];
group_label = [ones(13,1); 2*ones(17,1)];

%--------------------------------------------------------------------------
% 2. Statistical test: Mann-Whitney U
%--------------------------------------------------------------------------
[p, ~] = ranksum(Severe, Moderate);

%--------------------------------------------------------------------------
% 3. Figure setup
%--------------------------------------------------------------------------
fig = figure('Color','w','Position',[50,50,1400,1000]);
subplot(2,3,1)

% Boxplot
boxplot(all_data, group_label, ...
    'Labels',{'Severe','Moderate'}, ...
    'Widths',0.6, 'Colors','k', 'Symbol','o', ...
    'OutlierSize',4, 'Whisker',1.5, 'BoxStyle','outline');

% Semi-transparent box fill
col = [0 0.4470 0.7410; 0.8500 0.3250 0.0980];
boxobj = findobj(gca,'Tag','Box');
for i = 1:2
    patch(get(boxobj(i),'XData'), get(boxobj(i),'YData'), ...
        col(i,:), 'FaceAlpha',0.5, 'LineWidth',1.1);
end

% Line width and axes
allline = findobj(gca,'Type','line');
set(allline,'LineWidth',1.5);
set(gca,'Box','on','LineWidth',1.5);
grid off;
hold on;

%--------------------------------------------------------------------------
% 4. Jittered scatter points
%--------------------------------------------------------------------------
scatter_col = [0.8500 0.3250 0.0980; 0 0.4470 0.7410];
for g = 1:2
    if g == 1
        y = Severe;
    else
        y = Moderate;
    end
    x = g + (rand(size(y)) - 0.5) * 0.2;
    scatter(x, y, 100, scatter_col(g,:), 'filled', ...
        'MarkerEdgeColor','white', 'LineWidth',2);
end

%--------------------------------------------------------------------------
% 5. Significance bracket
%--------------------------------------------------------------------------
y_max  = max(all_data);
y_line = y_max * 1.12;
y_txt  = y_max * 1.16;

plot([1,2],[y_line,y_line],'k','LineWidth',1.2);
plot([1,1],[y_line,y_line*0.95],'k','LineWidth',1.2);
plot([2,2],[y_line,y_line*0.95],'k','LineWidth',1.2);

sigstr = sprintf('p = %.4f', p);
text(1.5, y_txt, sigstr, 'FontName','Arial', 'FontSize',14, ...
    'HorizontalAlignment','center');

%--------------------------------------------------------------------------
% 6. Axes formatting
%--------------------------------------------------------------------------
set(gca,'FontName','Arial','FontSize',18);
ylabel('Duration of grade 2 neutropenia (days)', ...
    'FontName','Arial','FontSize',18);
ylim([20, max(all_data) * 1.25]);
hold off;

% -------- Save Figure --------
if ~isempty(outputDir)
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    outFile = fullfile(outputDir, 'Figure_5C.png');
    exportgraphics(fig, outFile, 'Resolution', 300);
    fprintf('Saved: %s\n', outFile);
end

end
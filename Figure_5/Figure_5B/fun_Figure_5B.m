function fun_Figure_5B(T,Y, Neu)
%==========================================================================
% fun_Figure_5B
% Figure 5B: Time-course profile of circulating neutrophil concentration
% Logarithmic y-axis. Model predicted curve + observed average neutrophil data.
% Shaded bands for severity levels; rectangular patches for chemotherapy cycles;
% triangle markers for G-CSF injection time points.
%
% Input variables required in workspace: T, Y, Neu
% Required toolbox: MATLAB base
%==========================================================================

%--------------------------------------------------------------------------
% 1. Figure canvas setup
%--------------------------------------------------------------------------
figure('Color','w','Position',[50 50 1400 1000]);
subplot(3,4,[1,2,3,5,6,7]);
hold on;

%--------------------------------------------------------------------------
% 2. Shaded severity level bands
%--------------------------------------------------------------------------
y_fill(1,:) = [0.01,0.01,0.357,0.357];
y_fill(2,:) = [0.357,0.357,0.714,0.714];
y_fill(3,:) = [0.714,0.714,1.07,1.07];
x_fill = [0,63,63,0];

color = [230, 111, 81;
         246, 241, 147;
         197, 235, 170]./255;

for i = 1:size(color,1)
    fill(x_fill, y_fill(i,:), color(i,:), ...
        'FaceAlpha', 0.5, ...
        'EdgeColor', [169, 169, 169]./255, ...
        'LineWidth',1);
end

%--------------------------------------------------------------------------
% 3. Model predicted neutrophil time curve
%--------------------------------------------------------------------------
T_start = 1 + 16*21 * 24*10; 
time_offset = T(T_start);
adjusted_time = (T(T_start:end) - time_offset) ./ 24;

plot(adjusted_time, Y(1,T_start:end), '-', ...
    'LineWidth', 2, ...
    'Color', [150 54 52]./255);
plot(adjusted_time, Y(2,T_start:end), '-', ...
    'LineWidth', 2, ...
    'Color', [59, 130, 246]./255);
%--------------------------------------------------------------------------
% 4. Observed average neutrophil data points (remove NaN)
%--------------------------------------------------------------------------
time_points = [0, 4, 21, 25, 42, 46];
data_severe = Neu(1,:);
data_moderate = Neu(2,:);

scatter(time_points, data_severe, ...
    'o', 'filled', ...
    'MarkerEdgeColor', [255, 255, 255]./255, ...
    'MarkerFaceColor', [122, 46, 56]./255, ...
    'SizeData', 100);
scatter(time_points, data_moderate, ...
    's', 'filled', ...
    'MarkerEdgeColor', [255, 255, 255]./255, ...
    'MarkerFaceColor', [59, 130, 246]./255, ...
    'SizeData', 100);
%--------------------------------------------------------------------------
% 5. Chemotherapy shaded rectangle & G-CSF injection markers
%--------------------------------------------------------------------------
X_fill = [1,15,15,1];
Y_fill = [90,90,100,100];
color_Cap = [102, 153, 204]./255;

for i = 1:3
    fill(X_fill + 21*(i-1), Y_fill, color_Cap, ...
        'FaceAlpha', 1, ...
        'EdgeColor', [169, 169, 169]./255, ...
        'LineWidth',1);
    scatter(2 + 21*(i-1), 120, 100, 'v','filled',...
        'MarkerFaceColor',[17, 119, 51]./255);
end

%--------------------------------------------------------------------------
% 6. Legend
%--------------------------------------------------------------------------
leg = legend('Grade 3','Grade 2','Grade 1','Severe curve','Moderate curve','Severe data','Moderate data','Chemotherapy','G-CSF injection time',...
    'Location','southoutside','Orientation','horizontal','NumColumns', 5);
set(leg,'EdgeColor',[0.65 0.65 0.65],'FontName','Arial','FontSize',16);

%--------------------------------------------------------------------------
% 7. Axes formatting (log scale)
%--------------------------------------------------------------------------
ax = gca;
box on;
set(ax, 'YScale', 'log');
xlim(ax, [0,63]);
ylim(ax, [0.05,250]);
yticks(ax, [0.1, 1, 10, 100]);
yticklabels(ax, {'0.1', '1', '10', '100'});

set(ax, ...
    'YMinorTick', 'off', ...
    'XMinorTick', 'off', ...
    'GridLineStyle', '-', ...
    'GridAlpha', 0.3, ...
    'GridColor', [0.8,0.8,0.8], ...
    'MinorGridLineStyle', 'none');
grid(ax, 'on');

set(gca,'FontName','Arial', 'FontSize', 16,'LineWidth', 1.5);
xlabel('Time (days)','FontName','Arial','FontSize',16);
ylabel({'Circulating neutrophil (10^8 cells/kg)'},'FontName','Arial','FontSize',16);

hold off;

end

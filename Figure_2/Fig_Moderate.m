function Fig_Moderate(n)
raw_data = Data();
Time = raw_data(1, :);  
PatientData = raw_data(2:end, :);  

col5_data = PatientData(:, 5);       
valid_idx = ~isnan(col5_data);       
valid_col5 = col5_data(valid_idx);   
valid_patient = PatientData(valid_idx, :); 

% >1 CTCAE v6.0
idx_gt1 = valid_col5 > 1;
PatientData_gt1 = valid_patient(idx_gt1, :); % CTCAE v6.0 >1 
%% Figure
% figure('Position',[50 50 1400 1000])
subplot(2,3,n)
hold on; grid off; box off;
shade_intervals = [1 15; 22 36; 43 57]; 
y_min = 0.4;
y_max = 23;

for i = 1:size(shade_intervals,1)
    x1 = shade_intervals(i,1);
    x2 = shade_intervals(i,2);
    fill([x1,x2,x2,x1], [y_min,y_min,y_max,y_max], [1,0.8,0.8], 'FaceAlpha',0.4, 'EdgeColor','none');
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
for i = 1:size(PatientData_gt1, 1)
    patient_vals = PatientData_gt1(i, :);
    valid_time_idx = ~isnan(patient_vals); 
    valid_times = Time(valid_time_idx);    
    valid_vals = patient_vals(valid_time_idx); 
    
    scatter(valid_times, valid_vals, 80, [0.8,0,0], 'filled', 'Marker','o'); 
end
hold on

PatientData_gt1_col_clean = cell(1, size(PatientData_gt1, 2)); 

for col = 1:size(PatientData_gt1, 2)
    col_data = PatientData_gt1(:, col);
    col_data_clean = col_data(~isnan(col_data));
    PatientData_gt1_col_clean{col} = col_data_clean;
end

for col = 1:size(PatientData_gt1_col_clean, 2)
    col_data = PatientData_gt1_col_clean{col};
    if ~isempty(col_data)
        col_mean_vector(col) = mean(col_data);
    else
        col_mean_vector(col) = NaN; 
    end
end

plot(Time, col_mean_vector, 'Color',[0.8,0,0], 'LineWidth', 2); 

%%
xlabel('Time (day)');
ylabel('Circulating Neutrophils (10^9 cells/L)');
xlim([0, 60]); 
ylim([0.4, y_max]);
ax = gca;
ax.FontSize = 16;
ax.LineWidth = 1.5;
set(ax,'YScale','log')
ax.XTick = [0, 20, 40, 60]; 
ax.XTickLabel = {'0','20','40','60'}; 
ax.YTick = [1, 10];
ax.YTickLabel = {'1','10'}; 

plot([0,66], 1*ones(1,2),'--', 'Color',[0,0,0], 'LineWidth', 1.5); 
plot([0,66], 0.5*ones(1,2),'--', 'Color',[0,0,0], 'LineWidth', 1.5); 

hold off
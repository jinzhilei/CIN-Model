function picture_PK(t_days,C_cap,C_csf,P_csf)

close all
%% Plot Cap data

figure(1);
plot(t_days, C_cap, 'LineWidth', 2,'Color',[200 0 200]./255);grid on;hold on;
x = [0.04 0.08 0.17 0.25 0.3 0.5];y = [5.2 4.0 3.1 2.4 1.5 0.6]; 
err = [1.3 1.1 0.8 0.9 0.7 0.3];e=errorbar(x,y,err,"LineStyle","none");
e.Marker = '.';e.MarkerSize = 40;e.LineWidth = 1.5;e.Color = [139 0 139]./255;e.CapSize = 15;
R2_cap = calculate_R2(y,C_cap(round(x.*10.*24)));
text(0.3,4,strcat('R^2=',num2str(R2_cap)),'FontSize',18,'FontWeight','bold','Color',[139 0 139]./255);
set(gca,'FontSize',16); set(gca,'FontName','Arial'); xlim([0,0.5]);ylim([0,8]);
xlabel('Time (day)');ylabel('Capecitabine (\mug/mL)');title('Pharmacokinetic curve of capecitabine');
legend('Numerical simulation (1500 \mug)','Experimental data (1500 \mug)','FontSize',16,'Location','northeast');
set(gcf,'unit','centimeters','position',[45 4 14 13]);
print('Figure\Capecitabine_data','-dpng','-r600');

%% Plot G-CSF data

figure(2);

x = [0.0417 0.0625 0.083 0.17 0.25 0.33 0.5 1];
y1 = [3.60 6.90 9.36 14.81 13.07 8.41 2.33 0];  % 300 ug
y2 = [0.93 1.67 3.03 4.33  2.90  1.84 0.59 0];  % 150 ug
y3 = [0.37 0.63 0.80 1.50  1.10  0.80 0.16 0];  % 75  ug

plot(t_days, C_csf(:,1), 'LineWidth', 2,'Color', [255 48 48]./255);grid on;hold on;
R2_csf_1 = calculate_R2(y1,C_csf(round(x.*10.*24),1).');
plot(x, y1, 'o','MarkerFaceColor',[205 38 38]./255,'MarkerEdgeColor',[205 38 38]./255,'MarkerSize', 10);
text(0.6,13,strcat('R^2=',num2str(R2_csf_1)),'FontSize',18,'FontWeight','bold','Color',[205 38 38]./255);

plot(t_days, C_csf(:,2), 'LineWidth', 2,'Color', [0 205 0]./255);
R2_csf_2 = calculate_R2(y2,C_csf(round(x.*10.*24),2).');
plot(x, y2, 'o','MarkerFaceColor',[0 180 0]./255,'MarkerEdgeColor',[0 180 0]./255,'MarkerSize', 10);
text(0.6,10,strcat('R^2=',num2str(R2_csf_2)),'FontSize',18,'FontWeight','bold','Color',[0 180 0]./255);

plot(t_days, C_csf(:,3), 'LineWidth', 2,'Color', [30 144 255]./255);
R2_csf_3 = calculate_R2(y3,C_csf(round(x.*10.*24),3).');
plot(x, y3, 'o','MarkerFaceColor',[24 116 205]./255,'MarkerEdgeColor',[24 116 205]./255,'MarkerSize', 10);
text(0.6,7,strcat('R^2=',num2str(R2_csf_3)),'FontSize',18,'FontWeight','bold','Color',[24 116 205]./255);

set(gca,'FontSize',16); set(gca,'FontName','Arial'); xlim([0,1]);ylim([0,25]);
xlabel('Time (day)');ylabel('G-CSF (ng/mL)');title('Pharmacokinetic curve of G-CSF');
legend('Numerical simulation (300 \mug)','Experimental data (300 \mug)', ...
    'Numerical simulation (150 \mug)','Experimental data (150 \mug)', ...
    'Numerical simulation (75 \mug)','Experimental data (75 \mug)','FontSize',14,'Location','northeast');
set(gcf,'unit','centimeters','position',[45 4 14 13]);
print('Figure/G-CSF_data','-dpng','-r600');

end
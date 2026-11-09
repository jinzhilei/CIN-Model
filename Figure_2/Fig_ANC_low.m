function Fig_ANC_low(m)
%% 
raw_data = Data();

for i = 1:3
data(:,i) = raw_data(:,i*2-1);
end

timeLab = string(data(1,:));
dat = data(2:end,:);
groupName = timeLab;
[n,~]=size(dat);

% figure('Position',[50 50 1400 1000])
subplot(2,3,m)

bp = boxplot(dat,'Labels',groupName,'Widths',0.5,'Colors',[0 0 0],'Symbol','o','OutlierSize',4,'Whisker',1.5,'BoxStyle','outline');

% 箱体填色
mycolor = [0 0.4470 0.7410;0.8500 0.3250 0.0980;0.4660 0.6740 0.1880];
boxobj = findobj(gca,'Tag','Box');
for i = 1:3
    patch(get(boxobj(i),'XData'),get(boxobj(i),'YData'),mycolor(i,:),'FaceAlpha',0.5,'LineWidth',1.1);
end

% 框线加粗
box_line = findobj(gca, 'Type', 'line');
set(box_line, 'LineWidth',1.5);
set(gca,'Box','on','LineWidth',1.5);
grid off;

hold on
%% 同一患者灰色连线
for i=1:n
    plot([1,2,3],dat(i,:),'Color',[0.6 0.6 0.6],'LineWidth',0.6);
end

%% 散点竖直对齐不抖动
sc_col = [0.4660 0.6740 0.1880;0.8500 0.3250 0.0980;0 0.4470 0.7410];
for i=1:3
    y = dat(:,i);
    x = repmat(i,size(y)); 
    scatter(x,y,60,sc_col(i,:),'filled','MarkerEdgeColor','white','LineWidth',2);
end

% Kruskal-Wallis 
[p_kw,~,stats] = kruskalwallis(dat,[],'off');
c = multcompare(stats,'Display','off');
p12 = c(1,6);  
p13 = c(2,6);

y_max = max(dat(:));
y1 = y_max*1.15; y2 = y_max*1.28;
% T1-T2显著性横线
plot([1,2],[y1,y1],'k','LineWidth',1);
plot([1,1],[y1,y1*0.95],'k','LineWidth',1);
plot([2,2],[y1,y1*0.95],'k','LineWidth',1);
text(1.5,y1*1.02,getSig(p12),'FontSize',20,'FontName','Arial','HorizontalAlignment','center');

% T1-T3显著性横线
plot([1,3],[y2,y2],'k','LineWidth',1);
plot([1,1],[y2,y2*0.95],'k','LineWidth',1);
plot([3,3],[y2,y2*0.95],'k','LineWidth',1);
text(2,y2*1.02,getSig(p13),'FontSize',20,'FontName','Arial','HorizontalAlignment','center');


ax = gca;
ax.FontSize = 16;
ax.LineWidth = 1.5;
ax.YTick = [1,2,3,4];
ax.YTickLabel = {'1','2','3','4'}; 
% xlabel('Time (day)');
ylabel('Circulating Neutrophils (10^9 cells/L)','FontName','Arial');
ylim([min(dat(:))*0.7,y_max*1.4]);
box off
set(gca,'FontName','Arial');

%% 
function s = getSig(p)
if p<0.001
    s='***';
elseif p<0.01
    s='**';
elseif p<0.05
    s='*';
else
    s='ns';
end
end


end
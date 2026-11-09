%==========================================================================
% Function: plotCircularDendrogram_3B
% Purpose: Generate circular dendrogram (radial tree) for Damage Index
%          Ward hierarchical clustering, fixed to 2 clusters (N=2)
% Input:    csvFile - string, csv file name, two columns y0, y1
% Output:   T       - cluster label vector for each sample
% Reference: slandarer circular dendrogram demo
%==========================================================================
function T = plotCircularDendrogram(csvFile)

%% Load data
data    = readmatrix(csvFile);
y0      = data(:,1);
y1      = data(:,2);

%% Construct feature and min-max normalization
X       = [1 - y0, y0 - y1];
X_norm  = (X - min(X)) ./ (max(X) - min(X));

%% Weighted fusion to compute Damage Index
w1 = 0.5;
w2 = 0.5;
Y  = X_norm(:,1) * w1 + X_norm(:,2) * w2;
Data = Y;

% Sample names: P1~P30
sampleName = compose('P%d', 1:30);
% Fixed number of clusters
N = 2;
className = compose('Class %d', 1:N);

% Font settings
sampleFont = {'FontSize', 18, 'FontName', 'Arial'};
classFont  = {'FontSize', 22, 'FontName', 'Arial', 'FontWeight', 'bold'};

% Radius parameters
RSet = [1+1/30, 1.22, 1.27, 1.35];
% Color palette
CList = lines(N);

%% Hierarchical clustering (Ward linkage, fixed 2 clusters)
Z = linkage(Data, 'ward');
num_clusters = 2;
T = cluster(Z, 'maxclust', num_clusters);
cutoff = median([Z(end-(N-1),3), Z(end-(N-2),3)]);

% Extract dendrogram line data
fig2 = figure();
[LineSet, ~, order] = dendrogram(Z, 0, 'Orientation', 'top');
XSet = reshape([LineSet(:).XData], 4, []).';
YSet = reshape([LineSet(:).YData], 4, []).';
close(fig2)

% Angle preprocess
TT = T(order);
theta1 = 0;
theta2 = 2*pi;
theta3 = (theta2-theta1)./size(Data,1);
theta4 = theta1 + theta3/2;
theta5 = theta2 - theta3/2;
maxY = max(max(YSet));
tS = linspace(0,1,50);

%% Create figure and axes
fig1 = figure('Units', 'normalized', 'Position', [.1,.1,.5,.8], 'Color', 'w');
ax1 = gca;
ax1.NextPlot = 'add';
ax1.DataAspectRatio = [1,1,1];
ax1.XColor = 'none';
ax1.YColor = 'none';
axis tight

% Plot circular dendrogram branches
tT = theta4 + (theta5-theta4).*(XSet-1)./(size(Data,1)-1);
tR = maxY-YSet;
tR = [tR(:,1), tR(:,2).*ones(1,50), tR(:,4)].';
tT = [tT(:,1), tT(:,2)+tS.*(tT(:,3)-tT(:,2)), tT(:,4)].';
plot(ax1, tR.*cos(tT), tR.*sin(tT), 'Color', 'k', 'LineWidth', .7);

% Plot sample labels (P1~P30)
for i = 1:length(order)
    tT = theta4 + (theta5-theta4).*(i-1)./(size(Data,1)-1);
    if tT<pi/2 || tT>3*pi/2
        text(ax1, maxY.*RSet(1).*cos(tT), maxY.*RSet(1).*sin(tT), sampleName{order(i)},...
            'FontSize', 22, 'Rotation', tT./pi.*180, sampleFont{:});
    else
        text(ax1, maxY.*RSet(1).*cos(tT), maxY.*RSet(1).*sin(tT), sampleName{order(i)},...
            'FontSize', 22, 'Rotation', tT./pi.*180+180, 'HorizontalAlignment', 'right', sampleFont{:});
    end
end

% Class boundary detection
XSet = [XSet(:,1:2); XSet(:,3:4)];
YSet = [YSet(:,1:2); YSet(:,3:4)];
BSet = (YSet(:,1)-cutoff).*(YSet(:,2)-cutoff)<0;
HSet = (YSet(BSet,1)+YSet(BSet,2))./2;
Cset = TT(round(XSet(BSet,1)));
classNum = unique(TT, 'stable');

% Draw class shaded sectors and labels
for i = 1:length(classNum)
    % Inner shaded sector
    tX = [find(TT==classNum(i),1,'first')-.5, find(TT==classNum(i),1,'last')+.5];
    tR = [maxY-HSet(Cset==classNum(i)), maxY];
    tT = theta4 + (theta5-theta4).*(tX-1)./(size(Data,1)-1);
    tR = [tR(1), tR(2).*ones(1,50), tR(1), tR(1).*ones(1,50)];
    tT = [tT(1), tT(1)+tS.*(tT(2)-tT(1)), tT(2), tT(2)+tS.*(tT(1)-tT(2))];
    patch(ax1, tR.*cos(tT), tR.*sin(tT), CList(i,:), 'EdgeColor', 'none', 'FaceAlpha', .25);
    
    % Outer color sector
    tX = [find(TT==classNum(i),1,'first')-.2, find(TT==classNum(i),1,'last')+.2];
    tR = maxY.*RSet(1,2:3);
    tT = theta4 + (theta5-theta4).*(tX-1)./(size(Data,1)-1);
    tR = [tR(1), tR(2).*ones(1,50), tR(1), tR(1).*ones(1,50)];
    tT = [tT(1), tT(1)+tS.*(tT(2)-tT(1)), tT(2), tT(2)+tS.*(tT(1)-tT(2))];
    patch(ax1, tR.*cos(tT), tR.*sin(tT), CList(i,:), 'EdgeColor', 'none', 'FaceAlpha', .9);
    
    % Class label
    tT = mean(tT);
    if tT<pi
        text(ax1, maxY.*RSet(4).*cos(tT), maxY.*RSet(4).*sin(tT), className{i}, 'Color', CList(i,:),...
            'FontSize', 16, 'Rotation', tT./pi.*180-90, 'HorizontalAlignment', 'center', classFont{:});
    else
        text(ax1, maxY.*RSet(4).*cos(tT), maxY.*RSet(4).*sin(tT), className{i}, 'Color', CList(i,:),...
            'FontSize', 16, 'Rotation', tT./pi.*180+180-90, 'HorizontalAlignment', 'center', classFont{:});
    end
end

end

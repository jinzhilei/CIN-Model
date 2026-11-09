%==========================================================================
% Function: plotDamageIndexClustering
% Purpose: Calculate damage index, perform Ward hierarchical clustering (fixed 2 clusters),
%          and plot histogram of damage index distribution for two subgroups
% Input: csvFile - string, path/name of csv file (two columns: y0, y1)
% Output: idx    - cluster label vector (1 or 2 for each sample)
%==========================================================================
function idx = plotDamageIndexClustering(csvFile)

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

%% Hierarchical clustering, fixed to 2 clusters, Ward linkage
D       = pdist(Y);
Z       = linkage(D, 'ward');
num_clusters = 2;
idx     = cluster(Z, 'maxclust', num_clusters);

%% Plot histogram
figure('Color','white','Position',[50 50 1500 1000]);
subplot(2,3,1);
hold on; grid on; box on;

for i = 1 : num_clusters
    idx_i = idx == 3 - i;
    a     = Y(idx_i, 1);
    histogram(a, 'NumBins', 6 - i);
end

xlim([0, 0.8]);
ylim([0, 8]);
xlabel('E_{injury}','FontSize',22,'FontName','Arial');
ylabel('Frequency','FontSize',22,'FontName','Arial');
set(gca, 'FontSize',22, 'LineWidth',1.5);
hold off;

end

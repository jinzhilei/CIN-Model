function main_Figure_2(outputDir)
%   main_Figure_2() creates a figure containing three subplots:
%       (1) ANC - low
%       (2) Moderate-Mild
%       (3) Severe- Grade2
%
%   main_Figure_2(outputDir) additionally saves the figure as a 300 dpi PNG in the given directory (/Figure).

    if nargin < 1
        outputDir = 'Figure';
    end

    fig = figure('Position', [50 50 1400 1000], 'Color', 'w');

    Fig_ANC_low(1);
    Fig_Moderate(2);
    Fig_Severe(3);

    if ~isempty(outputDir)
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        outFile = fullfile(outputDir, 'Figure_2.png');
        exportgraphics(fig, outFile, 'Resolution', 300);
        fprintf('Saved: %s\n', outFile);
    end
end
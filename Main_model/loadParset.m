function params = loadParset()
% LOADDATASET  Load the variable 'params' from PSO/params.mat.
%
%   params = loadDataset()  loads '<thisDir>/PSO/params.mat' and returns
%   the value of the variable named 'params' (NOT a struct container).

    thisDir = fileparts(mfilename('fullpath'));
    matFile = fullfile(thisDir, 'PSO', 'params.mat');
    % matFile = fullfile(thisDir, 'PSO_average', 'all_results.mat');

    if ~isfile(matFile)
        error('loadDataset:fileNotFound', 'MAT file not found: %s', matFile);
    end

    % 指定变量名 'params' 读取，S 只是临时容器
    S = load(matFile, 'params');
    % S = load(matFile, 'params_all');

    % 若文件中没有名为 params 的变量，给出清晰报错
    if ~isfield(S, 'params')
        error('loadDataset:noParams', ...
              'Variable ''params'' not found in: %s', matFile);
    end

    % 输出就是 params 变量本身（矩阵/向量/标量，视其内容而定）
    params = S.params;
end
function main_Figure_3(outputDir)
% MAIN_FIGURE_3 Generate a 5x6 subplot grid for 30 patients and save the figure.
%   main_Figure_3() saves the figure as a 300 dpi PNG in the default 'Figure' directory.
%   main_Figure_3(outputDir) saves the figure in the specified directory.

    % Handle input arguments for output directory
    if nargin < 1
        outputDir = 'Figure';
    end

    t_start = 0;                             
    n_cycles = 19;                           
    dt_hours = 0.1;                          
    cycle_length = 21;                       
    t_total_days = n_cycles * cycle_length;  
    t_end = t_total_days*24;                 
    th = 1; 
    %% 
    [neutrophil] = Data();  
    tic

    %% PK
    % Preheating cycle number, system reaches relative steady state
    wp_cycles = 15;                           
    wp_days = wp_cycles * cycle_length;
    dt_days = dt_hours/24;
    n_zero_points = ceil(wp_days/dt_days);   

    % warm-up period
    C_cap = simulate_capecitabine_concentration(n_cycles,dt_hours,cycle_length);
    C_csf = simulate_gcsf_concentration(n_cycles,dt_hours,cycle_length);
    C_csf(1:n_zero_points) = 0;
    C_cap(1:n_zero_points) = 0;

    %% Model option
    model = @HSCs_Cap_Gcsf_Model_new;        
    initial = [1.1,2.26,3.54,0.9];            

    % 5-Row 6-Column Arrangement
    fig = figure('Position',[50 50 1400 1000]); 

    for m = 1:30

        filename = sprintf('PSO/params_%d.mat', m);
        load(filename);

        Neu = neutrophil(m,:); 
        param_values = params_opt;
        [T, Y] = Solve(t_start, dt_hours, t_end, th, param_values, C_cap, C_csf, model, initial);

        subplot(5,6,m); 
        hold on

        x1_fill = [1,15,15,1];
        x2_fill = [1,15,15,1]+21;
        x3_fill = [1,15,15,1]+21*2;
        y_fill = [0.01,0.01,200,200];
        fill(x1_fill, y_fill, [245 224 224]./255, 'FaceAlpha',0.9,'EdgeColor','none');
        fill(x2_fill, y_fill, [245 224 224]./255, 'FaceAlpha',0.9,'EdgeColor','none');
        fill(x3_fill, y_fill, [245 224 224]./255, 'FaceAlpha',0.9,'EdgeColor','none');

        T_start = 1 + (wp_cycles+1)*cycle_length * 24/dt_hours;
        time_offset = T(T_start);
        adjusted_time = (T(T_start:end) - time_offset) ./ 24;
        plot(adjusted_time, Y(3,T_start:end), '-', 'LineWidth',2, 'Color',[150 54 52]./255);

        plot(T./24, ones(length(T),1)*0.714, '--', 'LineWidth',1.5, 'Color',[0 0 0]./255);
        plot(T./24, ones(length(T),1)*0.357, '--', 'LineWidth',1.5, 'Color',[242 44 57]./255);

        time_points = [0,4,21,25,42,46];
        data = Neu;
        valid_idx = ~isnan(data);
        time_valid = time_points(valid_idx);
        value_valid = data(valid_idx);
        scatter(time_valid, value_valid, 'filled', ...
                'MarkerEdgeColor',[244, 63, 94]./255,...
                'MarkerFaceColor',[122, 46, 56]./255,...
                'SizeData',40); 

        ax = gca;
        box on;
        set(ax,'FontName','Arial','FontSize',16,'LineWidth',1.5); % Subplot font size reduced

        set(ax,'YScale','log');
        xlim([0,63]);
        ylim([0.05,150]);

        xticks([0,20,40,60]);
        xticklabels({'0','20','40','60'});
        yticks([0.1,1,10,100]);
        yticklabels({'0.1','1','10','100'});
        set(ax,'YMinorTick','off','XMinorTick','off');
        grid on;
        set(ax, ...
        'YMinorTick', 'off', ...  
        'XMinorTick', 'off', ...  
        'GridLineStyle', '-', ...
        'GridAlpha', 0.3, ...
        'GridColor', [0.8,0.8,0.8], ...
        'MinorGridLineStyle', 'none');  
        grid(ax, 'on'); 

        % Sub icon annotation number
        title(sprintf('Patient:%d',m),'FontSize',12);

        hold off;
    end
    toc

    % -------- Save Figure --------
    if ~isempty(outputDir)
        if ~exist(outputDir, 'dir')
            mkdir(outputDir);
        end
        outFile = fullfile(outputDir, 'Figure_3.png');
        exportgraphics(fig, outFile, 'Resolution', 300);
        fprintf('Saved: %s\n', outFile);
    end
end
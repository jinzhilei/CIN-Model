function C_cap = simulate_capecitabine_concentration(n_cycles,dt_hours,cycle_length)

%% parameter setting

Fc = 0.8;                    % 生物利用度
Vcd = 186000;               % 分布容积 (mL)
ka_c = 2.75;                  % 吸收速率常数 (1/h)
kc_c = 0.2;                    % 消除速率常数 (1/h)
Dose_cap = 1500000;   % 1500000 

%% time setting

t_end = n_cycles * cycle_length * 24;  % 总模拟时间 (小时)=模拟的化疗周期数*化疗周期长度 (天)*24h
t = 0:dt_hours:t_end;        % 时间向量 (小时)

% Pharmacokinetic simulation

Chemo = zeros(size(t));      % Initialize the drug concentration
for i = 1:n_cycles
    % 计算每个周期的给药时间点
    t_i = (i-1) * 21 * 24; % 第i个周期的开始时间 (小时)

    % 1-14每日两次给药
    for day = 1:14
        for dose_time = [0, 12] % 每日两次给药时间
            dose_t = t_i + day*24 + dose_time;
            idx = t >= dose_t; % 创建一个逻辑索引向量
            Chemo(idx) = Chemo(idx) + Fc * Dose_cap / Vcd * (ka_c / (kc_c - ka_c)) * ...
                (exp(-ka_c*(t(idx)-dose_t)) - exp(-kc_c*(t(idx)-dose_t)));
        end
    end
end

C_cap=Chemo;

end




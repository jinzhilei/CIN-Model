function [x_out, y_out] = DDE_Euler(x0, h, xend, y0, th, C_cap, C_csf, model_handle, params)

% Initialize output arrays
x_data = [];
y_data = [];

% Store initial data and collect output
x_data(1) = x0;
y_data(:, 1) = y0(:, end);

% Iterative computation
x = x0;
y = y0;
[m, n] = size(y0);
y_old = zeros(m, n-1);
data_count = 1;

while x < xend
    k1 = model_handle(x, y, th, C_cap, C_csf, params);
    x = x + h;
    th = th + 1;
    y_old = y(:, 2:n);
    y = y + h * k1;  % Euler method update
    y = horzcat(y_old, y(:, n));
    
    data_count = data_count + 1;
    x_data(data_count) = x;
    y_data(:, data_count) = y(:, end);
end

% Return output vectors
x_out = x_data;
y_out = y_data;

end

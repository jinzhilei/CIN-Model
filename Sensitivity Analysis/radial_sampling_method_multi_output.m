function [mu, sigma] = radial_sampling_method_multi_output(model_func, param_ranges, num_levels, num_r)
% radial-sampling_cathod_multi_output performs global sensitivity analysis of radial sampling, suitable for multiple outputs
% Input parameters:
% model_func - Model Function Handle
% param_range - The range of parameters, with each row corresponding to the minimum and maximum values of a parameter
% num_1evels - Discretization level of parameters
% num_r - Number of Blocks
% Output:
% mu - the average impact size of the parameter, in matrix form, with each column corresponding to an output
% sigma - standard deviation of parameter influence, in matrix form, with each column corresponding to an output

    % Obtain the number of parameters
    num_params = size(param_ranges, 1);
    % Define the perturbation step size in Morris method
    delta = num_levels / (2 * (num_levels - 1));
    
    % Calculate the output dimension of a sample, assuming the model has one output
    num_outputs = 1;
    
    % Initialize output matrix: Each output corresponds to a sensitivity analysis result
    mu = zeros(num_params, num_outputs);
    sigma = zeros(num_params, num_outputs);

    % Main loop, generate r blocks based on the number of blocks
    for r = 1:num_r
        % Generate base point a and auxiliary point b
        a = param_ranges(:, 1) + (param_ranges(:, 2) - param_ranges(:, 1)) .* ...
               lhsdesign(num_params, 1, 'smooth', 'off') * (num_levels - 1) / num_levels;
        b = param_ranges(:, 1) + (param_ranges(:, 2) - param_ranges(:, 1)) .* ...
               lhsdesign(num_params, 1, 'smooth', 'off') * (num_levels - 1) / num_levels;
        
        % Calculate the output of base point a
        output_a = model_func(a);
        
        % Basic effects in initializing storage blocks
        effects = zeros(num_params, num_outputs);
        
        % Build a block and generate n+1 points
        for i = 1:num_params
            % Create the i+1th point in the block by replacing the i-th component of a with the corresponding component of b
            perturbed = a;
            perturbed(i) = b(i);
            output_perturbed = model_func(perturbed);
            
            % Calculate the basic effect value of this parameter on each output indicator
            for j = 1:num_outputs

                effects(i, j) = abs(output_perturbed(:,j) - output_a(:,j));

            end
            
            % Cumulative effect
            mu(i, :) = mu(i, :) + effects(i, :);
            sigma(i, :) = sigma(i, :) + effects(i, :).^2;
        end
    end
    
    % Calculate the average impact and standard deviation of each parameter
    mu = mu / num_r;
    sigma = sqrt(sigma / num_r - mu.^2);
end
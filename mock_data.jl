
function setup_population_data(num_units::Int, time_steps;
    d_dist=Normal(0.05, 0.01),
    y0_dist=Normal(1.0, 0.2),
    sigma_dist=Normal(0.01, 0.005))
    """
    Generate synthetic parameters and data for a population.

    Parameters:
    - num_units: Number of units in the population.
    - time_steps: Array of time points (e.g., 0:10).
    - d_dist: Distribution for degradation rates (default: Normal(0.05, 0.01)).
    - y0_dist: Distribution for initial outputs (default: Normal(1.0, 0.2)).
    - sigma_dist: Distribution for noise levels (default: Normal(0.01, 0.005)).

    Returns:
    - y: Matrix of simulated output data (rows = units, columns = time points).
    - t: Time points (Array).
    - true_d: Array of true degradation rates for each panel.
    - true_y0: Array of true initial outputs for each panel.
    - sigma: Array of noise standard deviations for each panel.
    """
    # Generate random parameters from the provided distributions
    true_d = rand(d_dist, num_units)        # Degradation rates
    true_y0 = rand(y0_dist, num_units)      # Initial outputs
    sigma = rand(sigma_dist, num_units)     # Noise standard deviations

    # Ensure sigma values are positive
    sigma = abs.(sigma)

    # Generate synthetic data using the earlier population data function
    y, t = generate_population_data(true_d, true_y0, sigma, time_steps);

    return y, t, true_d, true_y0, sigma
end

function generate_population_data(true_d::Vector{Float64}, true_y0::Vector{Float64}, sigma::Vector{Float64}, time_steps)
    """
    Generate synthetic data for a population of units.

    Parameters:
    - true_d: Array of true degradation rates (one per unit).
    - true_y0: Array of true initial outputs (one per unit).
    - sigma: Array of noise standard deviations (one per unit).
    - time_steps: Array of time points (e.g., 0:10).

    Returns:
    - y: Matrix of simulated output data (rows = units, columns = time points).
    - t: Time points (Array).
    """
    num_units = length(true_d)

    # Generate outputs for each unit
    y = [
        true_y0[i] * exp.(-true_d[i] .* time_steps) .+ randn(length(time_steps)) .* sigma[i]
        for i in 1:num_units
    ]

    # Combine results into a matrix (rows = units, columns = time points)
    return vcat(y...), time_steps;
end



# Generate synthetic data
function generate_synthetic_data(true_d, true_y0, sigma, time_steps)
    """
    Generate synthetic data for degradation.

    Parameters:
    - true_d: True degradation rate (scalar).
    - true_y0: True initial output (scalar).
    - sigma: Noise standard deviation (scalar).
    - time_steps: Array of time points (e.g., 0:10).

    Returns:
    - y: Simulated output data (Array).
    - t: Time points (Array).
    """
    y = [true_y0 * exp(-true_d * t) + randn() * sigma for t in time_steps]
    return y, time_steps
end
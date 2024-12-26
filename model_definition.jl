using Turing

# Define the Bayesian model
@model function degradation_model(y, t)
    """
    Define the Bayesian model for degradation.

    Parameters:
    - y: Observed outputs (Array).
    - t: Time points (Array).

    Returns:
    - Posterior distributions of d, y0, and sigma.
    """
    d ~ Normal(0.05, 0.01)  # Prior for degradation rate
    y0 ~ Normal(1.0, 0.2)   # Prior for initial output
    sigma ~ truncated(Normal(0.0, 0.1), 0, Inf)  # Prior for noise

    # For each time point, model the observed output (y[i]) as noisy data 
    # around the predicted output (y0 * exp(-d * t[i])).
    for i in 1:length(t)
        y[i] ~ Normal(y0 * exp(-d * t[i]), sigma)
    end
end

@model function population_degradation_model(y, t;
    mu_d_prior=Normal(0.05, 0.01),
    sigma_d_prior=truncated(Normal(0.0, 0.01), 0, Inf),
    mu_y0_prior=Normal(1.0, 0.2),
    sigma_y0_prior=truncated(Normal(0.0, 0.1), 0, Inf))
    """
    Bayesian model for a population of units with configurable priors.

    Parameters:
    - y: Matrix of observed outputs (rows = units, columns = time points).
    - t: Time points (Array).
    - Priors:
    - mu_d_prior: Prior for the mean degradation rate.
    - sigma_d_prior: Prior for the variability in degradation rates.
    - mu_y0_prior: Prior for the mean initial output.
    - sigma_y0_prior: Prior for the variability in initial outputs.

    Returns:
    - Posterior distributions of population and unit-specific parameters.
    """
    num_units = size(y, 1)  # Number of units (columns of y)
    num_timepoints = size(y, 2)  # Number of time points (rows of y)


    # Population-level priors
    mu_d ~ mu_d_prior                     # Mean degradation rate
    sigma_d ~ sigma_d_prior               # Variability in degradation rates
    mu_y0 ~ mu_y0_prior                   # Mean initial output
    sigma_y0 ~ sigma_y0_prior             # Variability in initial outputs
    # Unit-specific parameters
    d = Vector{Real}(undef, num_units)
    y0 = Vector{Real}(undef, num_units)

    for i in 1:num_units
        d[i] ~ Normal(mu_d, sigma_d)      # Degradation rate for unit i
        y0[i] ~ Normal(mu_y0, sigma_y0)   # Initial output for unit i
        
        # Likelihood for each unit's outputs
        for j in 1:num_timepoints
            y[i, j] ~ Normal(y0[i] * exp(-d[i] * t[j]), 0.01)  
        end
    end
end



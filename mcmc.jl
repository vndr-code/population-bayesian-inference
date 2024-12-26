# Run MCMC Sampling
function run_mcmc(y, t; num_samples=1000, num_chains=4)
    """
    Perform MCMC sampling using Turing.jl.

    Parameters:
    - y: Observed outputs (Array).
    - t: Time points (Array).
    - num_samples: Number of MCMC samples (default: 1000).
    - num_chains: Number of MCMC chains (default: 4).

    Returns:
    - chain: MCMC chain with posterior samples.
    """
    model = degradation_model(y, t)
    sampler = NUTS(0.65)
    chain = sample(model, sampler, MCMCThreads(), num_samples, num_chains)
    return chain
end

# Run MCMC Sampling for population with configurable priors
function run_mcmc_pop(y, t;
    num_samples=1000,
    num_chains=4,
    mu_d_prior=Normal(0.05, 0.01),
    sigma_d_prior=truncated(Normal(0.0, 0.01), 0, Inf),
    mu_y0_prior=Normal(1.0, 0.2),
    sigma_y0_prior=truncated(Normal(0.0, 0.1), 0, Inf))
    """
    Perform MCMC sampling using Turing.jl with configurable priors.

    Parameters:
    - y: Matrix of observed outputs (rows = units, columns = time points).
    - t: Time points (Array).
    - num_samples: Number of MCMC samples (default: 1000).
    - num_chains: Number of MCMC chains (default: 4).
    - mu_d_prior: Prior for the mean degradation rate.
    - sigma_d_prior: Prior for the variability in degradation rates.
    - mu_y0_prior: Prior for the mean initial output.
    - sigma_y0_prior: Prior for the variability in initial outputs.

    Returns:
    - chain: MCMC chain with posterior samples.
    """


    # Call the population model with the given priors
    model = population_degradation_model(y, t;
        mu_d_prior=mu_d_prior,
        sigma_d_prior=sigma_d_prior,
        mu_y0_prior=mu_y0_prior,
        sigma_y0_prior=sigma_y0_prior)

    # Run MCMC sampling
    sampler = NUTS(0.65)
    chain = sample(model, sampler, MCMCThreads(), num_samples, num_chains)
    return chain
end

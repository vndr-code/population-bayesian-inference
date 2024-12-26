using DataFrames

# Analyze and visualize results
function analyze_results(chain)
    """
    Analyze and visualize the posterior results.

    Parameters:
    - chain: MCMC chain with posterior samples.
    """
    println("Posterior summaries:")
    display(chain)
    plot(chain)
end

# Analyze and visualize population-level results
function analyze_results_summary(chain)
    """
    Summarize and visualize only population-level posterior results.

    Parameters:
    - chain: MCMC chain with posterior samples.
    """
    println("Summarized Population-Level Results:")

    # Define population-level parameters
    pop_params = [:mu_d, :sigma_d, :mu_y0, :sigma_y0]

    # Summarize each parameter
    for param in pop_params
        samples = chain[param]  # Extract samples for the parameter
        mean_val = mean(samples)
        std_val = std(samples)
        println("$param: mean = $mean_val, std = $std_val")
    end

    # Plot each population-level parameter
    for param in pop_params
        println("Plotting: $param")
        p = plot(chain, param; label="", title=string(param), xlabel="Iterations", ylabel="Value")
        display(p)  # Show the plot
    end

    rhat_vals = rhat(chain)

    rhat_df = DataFrame(rhat_vals)

    # Extract R-hat for specific parameters
    mu_d_rhat = rhat_df[rhat_df.parameters .== :mu_d, :rhat][1]
    sigma_d_rhat = rhat_df[rhat_df.parameters .== :sigma_d, :rhat][1]
    mu_y0_rhat = rhat_df[rhat_df.parameters .== :mu_y0, :rhat][1]
    sigma_y0_rhat = rhat_df[rhat_df.parameters .== :sigma_y0, :rhat][1]

    # Print the R-hat values
    println("R-hat for mu_d: ", mu_d_rhat)
    println("R-hat for sigma_d: ", sigma_d_rhat)
    println("R-hat for mu_y0: ", mu_y0_rhat)
    println("R-hat for sigma_y0: ", sigma_y0_rhat)

end


# Posterior Predictive Checks with Population-Level Parameters
function posterior_predictive_checks(chain, t; num_samples=100)
    """
    Perform posterior predictive checks using population-level parameters.

    Parameters:
    - chain: MCMC chain with posterior samples.
    - t: Time points (Array).
    - num_samples: Number of predictive samples to generate.

    Outputs:
    - Plot comparing observed vs. predicted outputs with uncertainty.
    """
    # Extract population-level parameters
    mu_d = mean(chain[:mu_d])
    sigma_d = mean(chain[:sigma_d])
    mu_y0 = mean(chain[:mu_y0])
    sigma_y0 = mean(chain[:sigma_y0])

    # Generate predictive samples
    predicted = [
        mean([
            # Simulate prediction at time t[j] using population-level parameters
            rand(Normal(mu_y0, sigma_y0)) * exp(-rand(Normal(mu_d, sigma_d)) * t[j]) +
            randn() * 0.01  # Add small noise
            for _ in 1:num_samples  # Repeat to capture variability
        ])
        for j in 1:length(t)  # Loop over time points
    ]

    # Plot the predicted outputs
    scatter(t, predicted, label="Predicted", xlabel="Time", ylabel="Output", legend=:top)
end



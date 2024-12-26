using Pkg

# Activate environment
Pkg.activate(".")
Pkg.instantiate()
Pkg.add("Turing")
Pkg.add("Random")
Pkg.add("Plots")
Pkg.add("StatsPlots")
Pkg.add("DataFrames")

include("mock_data.jl")
include("model_definition.jl")
include("mcmc.jl")
include("analysis.jl")

using Turing
using Random
using Plots
using StatsPlots

Random.seed!(42)

function inspect_population_data(true_d, true_y0, sigma, y)
    println("Degradation Rates (true_d): ", true_d)
    println("Initial Outputs (true_y0): ", true_y0)
    println("Noise Levels (sigma): ", sigma)
    println("Simulated Outputs (Rows = Units, Columns = Time Points):")
    println(y)
end

# check if you have multi threads, if not julia --threads=auto in terminal
if Threads.nthreads() == 1
    println("Warning: Only 1 thread available. Set JULIA_NUM_THREADS to enable multithreading.")
end
# Step 1
# Customize distributions
num_units = 2
time_steps = 0:10
d_dist = Normal(0.06, 0.02)   # Slightly higher degradation rates with more variability
y0_dist = Normal(1.2, 0.3)    # Higher initial outputs
sigma_dist = Normal(0.02, 0.01)  # More noise in the measurements

# Generate population data
y, t, true_d, true_y0, sigma = setup_population_data(num_units, time_steps; 
                                                     d_dist=d_dist, 
                                                     y0_dist=y0_dist, 
                                                     sigma_dist=sigma_dist);

# Inspect the data when needed
# inspect_population_data(true_d, true_y0, sigma, y)


# Step 2
# Define custom priors
mu_d_prior = Normal(0.06, 0.02)          # Custom mean degradation rate
sigma_d_prior = truncated(Normal(0.01, 0.005), 0, Inf)  # Custom variability in degradation rates
mu_y0_prior = Normal(1.2, 0.3)           # Custom mean initial output
sigma_y0_prior = truncated(Normal(0.0, 0.15), 0, Inf)  # Custom variability in initial outputs

# Run MCMC
#chain = run_mcmc(y, t, num_samples=1000, num_chains=4)

# Run MCMC with configurable priors
chain = run_mcmc_pop(y, t; 
                     num_samples=1000, 
                     num_chains=4, 
                     mu_d_prior=mu_d_prior, 
                     sigma_d_prior=sigma_d_prior,
                     mu_y0_prior=mu_y0_prior,
                     sigma_y0_prior=sigma_y0_prior)


# Step 3
# Analyze results
analyze_results_summary(chain)

# Step 4
# Posterior Predictive Checks
posterior_predictive_checks(chain, t)

all: results/full_summary.md

# Compress data
data/exoTrain.rds: src/dat_prep.R data/exoTrain.csv
	Rscript src/dat_prep.R ./data/exoTrain.csv ./data/exoTrain.rds

data/exoTest.rds: src/dat_prep.R data/exoTest.csv
	Rscript src/dat_prep.R ./data/exoTest.csv ./data/exoTest.rds

# Extract and process data and save to temporary csv
data/quick_summary.csv: src/dat_sum.R ./data/exoTrain.rds
	@read -p "Enter a star index [1-3000]: " INDEX; \
	echo "Generating plots for star $$INDEX ..."; \
	Rscript src/dat_sum.R ./data/exoTrain.rds ./data/quick_summary.csv $$INDEX

# Plot the processed data and save the plots
results/figures/flux_compare.png results/figures/flux_original.png results/figures/freq_plot_zoom.png: src/dat_viz.R ./data/quick_summary.csv
	Rscript src/dat_viz.R ./data/quick_summary.csv ./results/figures/

# Save test results to csv
results/errors.csv results/confusion.csv: src/save_test.R data/exoTest.rds bin/rf_fit2
	Rscript src/save_test.R

# Render the report
TARGET_DEPS := data/quick_summary.csv results/figures/flux_compare.png
TARGET_DEPS += results/figures/flux_original.png results/figures/freq_plot_zoom.png
TARGET_DEPS += src/full_summary.Rmd
TARGET_DEPS += results/errors.csv results/confusion.csv

results/full_summary.md: $(TARGET_DEPS)
	Rscript -e 'ezknitr::ezknit("./src/full_summary.Rmd", out_dir = "./results")'

# Re-build model and save to bin
bin/rf_fit2: data/exoTrainReduced.rds
	Rscript src/build_mdl_reduce.R

# Clean data/quick_summary.csv to trigger new make all
clean:
	rm -f data/quick_summary.csv
	# rm -f results/figures/*.png
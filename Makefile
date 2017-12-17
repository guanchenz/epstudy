# Driver script
# GZ, Dec. 15, 2017
# Completes demonstration of exoplanets detection (from raw data to rendering report)
#
# usage:
# - make all: generate the full report
# - make plots: generate plots for a selected star
# - make bin/rf_fits: re-train the machine learning model with new training data
# - make clean: clean one intermediate file to allow rendering results for a new star
# - make clean_all: clean all intermediate results

all: doc/full_summary.md Makefile.png

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

doc/full_summary.md: $(TARGET_DEPS)
	Rscript -e 'ezknitr::ezknit("./src/full_summary.Rmd", out_dir = "./doc")'

# Draw dependency graph using makefile2graph
Makefile.png: Makefile
	makefile2graph > Makefile.dot
	dot -Tpng Makefile.dot -o Makefile.png

# Re-build model and save to bin
bin/rf_fit2: data/exoTrainReduced.rds
	Rscript src/build_mdl_reduce.R

# Save new images (if you only need to see the plots for a star)
plots: src/dat_viz.R ./data/quick_summary.csv
	Rscript src/dat_viz.R ./data/quick_summary.csv ./results/figures/

# Clean data/quick_summary.csv to trigger new make all
# Keep images for report
clean:
	rm -f data/quick_summary.csv

# Remove all intermediate files
clean_all:
	rm -f data/quick_summary.csv
	rm -f results/figures/*.png
	rm -f results/*.csv
	rm -f doc/full_summary.html

all: results/full_summary.md

data/exoTrain.rds: src/dat_prep.R data/exoTrain.csv
	Rscript src/dat_prep.R ./data/exoTrain.csv ./data/exoTrain.rds

data/exoTest.rds: src/dat_prep.R data/exoTest.csv
	Rscript src/dat_prep.R ./data/exoTest.csv ./data/exoTest.rds

results/quick_summary.csv: src/dat_sum.R ./data/exoTrain.rds
	@read -p "Enter a star index [1-3000]: " INDEX; \
	echo "Generating plots for star $$INDEX ..."; \
	Rscript src/dat_sum.R ./data/exoTrain.rds ./results/quick_summary.csv $$INDEX

results/figures/flux_compare.png results/figures/flux_original.png results/figures/freq_plot_zoom.png: src/dat_viz.R ./results/quick_summary.csv
	Rscript src/dat_viz.R ./results/quick_summary.csv ./results/figures/

results/full_summary.md: results/quick_summary.csv results/figures/flux_compare.png results/figures/flux_original.png results/figures/freq_plot_zoom.png src/full_summary.Rmd
	Rscript -e 'ezknitr::ezknit("./src/full_summary.Rmd", out_dir = "./results")'

clean:
	rm -f results/quick_summary.csv
	# rm -f results/figures/*.png
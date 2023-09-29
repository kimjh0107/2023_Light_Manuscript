manuscript: manuscript/manuscript.docx

manuscript/manuscript.docx: manuscript/manuscript.Rmd\
							manuscript/manuscript_style.docx\
							manuscript/nature.csl\
							manuscript/index.Rmd
	Rscript -e "bookdown::render_book('manuscript/', 'bookdown::word_document2')"

figure1c: figure/figure1/figure1C.pdf
figure/figure1/figure1C.pdf: src/figure1/figure1C_merge.R\
					src/figure1/figure1C_drymass_boxplot.R\
					src/figure1/figure1C_nucleus_boxplot.R\
					src/figure1/figure1C_overall_boxplot.R
	Rscript $<
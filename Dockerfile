# Copyright (c) 2016 HIPERFIT
# Authors:
#   Martin Dybdal <dybber@dybber.dk> 2016-03-08
#   Oleks <oleks@oleks.info> 2016-03-08

FROM jupyter/r-notebook

# Set default CRAN repo on R startup
RUN echo 'options("repos"="http://cran.rstudio.com")' >> ${HOME}/.Rprofile

# Install fancy packages for Financial Recipes
RUN Rscript -e "install.packages(c('randtoolbox', 'ggplot2'))"

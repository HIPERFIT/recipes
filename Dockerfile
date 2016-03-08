# Installs R, Jupyter Notebook, IRkernel (R for Jupyter), ggplot2+randtoolbox and our configuration file

FROM jupyter/notebook

# Retrieve recent R binary from CRAN
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/">>/etc/apt/sources.list && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --force-yes --no-install-recommends \
        r-base r-base-dev && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# Set default CRAN repo
RUN echo 'options("repos"="http://cran.rstudio.com")' >> /usr/lib/R/etc/Rprofile.site

# Install IRkernel
RUN Rscript -e "install.packages(c('rzmq','repr','IRkernel','IRdisplay'), repos = c('http://irkernel.github.io/', getOption('repos')))" -e "IRkernel::installspec()"

# Install other packages necessary for Financial Recipes
RUN Rscript -e "install.packages(c('randtoolbox', 'ggplot2'), repos = c('http://irkernel.github.io/', getOption('repos')))"

# Copy Jupyter configuration
COPY jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py

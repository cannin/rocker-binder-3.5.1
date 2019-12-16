FROM rocker/binder:3.5.1

USER root
RUN apt-get -qq update && \
apt-get install --yes --no-install-recommends openjdk-8-jdk && \
apt-get -qq purge && \
apt-get -qq clean && \
rm -rf /var/lib/apt/lists/*

# Copy your repository contents to the image
COPY --chown=rstudio:rstudio . ${HOME}

# We always want containers to run as non-root
USER rstudio

# Add project specific content
COPY packages /home/rstudio/packages
COPY example /home/rstudio/example
RUN chown -R rstudio:rstudio /home/rstudio

## Run an install.R script, if it exists.
RUN if [ -f install.R ]; then R --quiet -f install.R; fi

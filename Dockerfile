FROM rocker/geospatial:3.5.1
LABEL maintainer="Steve Lane"
LABEL email="lane.s@unimelb.edu.au"

## Install rust
RUN apt-get update  \
  && apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    cargo \
    ed \
    gcc \
    libnlopt-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

## Options for building
RUN mkdir -p $HOME/.R/ \
  && echo "CXXFLAGS=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -flto -ffat-lto-objects  -Wno-unused-local-typedefs -Wno-ignored-attributes -Wno-deprecated-declarations\n" >> $HOME/.R/Makevars \
  && echo "rstan::rstan_options(auto_write = TRUE)\n" >> /home/rstudio/.Rprofile \
  && echo "options(mc.cores = parallel::detectCores())\n" >> /home/rstudio/.Rprofile \
  && echo "options(Ncpus = parallel::detectCores())\n" >> /home/rstudio/.Rprofile

## Add in required packages
RUN . /etc/environment \ 
  && install2.r --error --repos $MRAN --deps TRUE \
    ggforce \
    ggmap \
    here \
    knitr \
    leaflet \
    recipes \
    rnaturalearth \
    rnaturalearthdata \
    rsample \
    shiny

RUN . /etc/environment \ 
  && install2.r --error --repos $MRAN --deps TRUE \
    bayesplot \
    rstan \
    rstanarm \
    rstantools \
    shinystan \
    scales \
    viridis

## Extras from github/bitbucket
RUN . /etc/environment \
  && installRepo.r SteveLane/steveMisc \
  && installRepo.r -r bitbucket cebra/surveillanceAllocation

# Remove unnecessary tmp files
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

CMD /bin/bash

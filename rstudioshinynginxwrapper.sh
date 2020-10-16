#!/bin/bash
# R/RStudio/Shiny-Server/nginx on Ubuntu

# Add repository to APT sources.list
echo deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/ | sudo tee --append /etc/apt/sources.list

# Add keys
gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | sudo apt-key add -

# Update repository list and install R
sudo apt-get update && sudo apt-get install r-base r-base-dev -y

# Install RStudio-Server
sudo apt-get install gdebi-core -y
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.3.959-amd64.deb
sudo gdebi --non-interactive rstudio-server-1.3.959-amd64.deb
rm rstudio-server-1.3.959-amd64.deb

# Install nginx
sudo apt-get install nginx -y

# Configure nginx with RStudio-Server and Shiny-Server virtualhosts
sudo cp default /etc/nginx/sites-enabled/default

# Install Ubuntu packages
sudo apt-get update && sudo apt-get install -y \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libxml2-dev 	
    
sudo apt-get update \
  && sudo apt-get install -y --no-install-recommends \
    lbzip2 \
    libfftw3-dev \
    libgdal-dev \
    libgeos-dev \
    libgsl0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libhdf4-alt-dev \
    libhdf5-dev \
    libjq-dev \
    liblwgeom-dev \
    libpq-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    libsqlite3-dev \
    libudunits2-dev \
    netcdf-bin \
    postgis \
    protobuf-compiler \
    sqlite3 \
    tk-dev \
    unixodbc-dev \
    libv8-dev \
    libnode-dev \
    libmariadbd-dev \
    libmariadbclient-dev \
    libcurl4-openssl-dev \
    libssh2-1-dev 

# add addition system dependencies but suffixing \ <package name> on the end of the apt-get update & apt-get install -y command

# Install Shiny R package
mkdir -p ~/R/x86_64-pc-linux-gnu-library/4.0
R -e "install.packages('shiny', repos='https://cran.rstudio.com/', lib='~/R/x86_64-pc-linux-gnu-library/4.0')"

#Install other common R packages
R -e "install.packages(c('directlabels','shinydashboard','ggplot2','plotly','scales','forcats','stringr','DT','readxl','tidyr','zoo','lubridate','reshape2','lemon','RColorBrewer','networkD3','shinyWidgets','shinyjs','shinycssloaders','openxlsx','readr','gcookbook','ggrepel','readODS','doBy','rtweet','httpuv','purrr','tm','wordcloud','jsonlite','lda','LDAvis','udpipe','lattice','tidytext','knitr','rmarkdown','readxl','htmltools','bs4Dash'),repos='https://cran.rstudio.com/', lib='~/R/x86_64-pc-linux-gnu-library/4.0')"
     
R -e "install.packages(c('tidyverse','dplyr','devtools','formatR','remotes','selectr','caTools','BiocManager',repos='https://cran.rstudio.com/', lib='~/R/x86_64-pc-linux-gnu-library/4.0'))"
 
R -e "install.packages(c('RColorBrewer','RandomFields','RNetCDF','classInt','deldir','gstat','hdf5r','lidR','mapdata','maptools','mapview','ncdf4','proj4','raster','rgdal','rgeos','rlas','sf','sp','spacetime','spatstat','spdep','geoR','geosphere'), repos='http://r-forge.r-project.org/')"

R -e "install.packages(c('forcats','shinycssloaders','odbc','fs','rlang','tibble','survey','stringr','survey','mosaic','DBI','fs','lubridate','magrittr','yaml','knitr','rmarkdown','testthat'))"

R -e "install.packages(c('directlabels'), repos='http://r-forge.r-project.org/')" && rm -rf /tmp/downloaded_packages

# Install Shiny-Server
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.14.948-amd64.deb
sudo gdebi --non-interactive shiny-server-1.5.14.948-amd64.deb
rm shiny-server-1.5.14.948-amd64.deb

# Configure Shiny-Server
sudo cp shiny-server.conf /etc/shiny-server/shiny-server.conf
sudo sed -i "s/run_as shiny/run_as $USER/" /etc/shiny-server/shiny-server.conf
sudo sed -i "s/site_dir \/srv\/shiny-server/site_dir \/home\/$USER\/shiny/" /etc/shiny-server/shiny-server.conf
mkdir $HOME/shiny

# Copy sample apps to users new Shiny dir
cp -r /opt/shiny-server/samples/sample-apps/hello/ ~/shiny

# Restart services
sudo systemctl restart nginx
sudo systemctl enable nginx
sudo systemctl restart shiny-server

#Tell user everything works
echo "nginx is now hosting a webpage on http://127.0.0.1"
echo "RStudio Server is now available on http://127.0.0.1:8787 & http://127.0.0.1/rstudio"
echo "Shiny Server is now available on http://127.0.0.1:3838 & http://127.0.0.1/shiny"

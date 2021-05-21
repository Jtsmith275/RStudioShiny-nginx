#!/bin/bash
# Update R/RStudio Server/Shiny Server/nginx on Ubuntu

# Update repository list and install R
sudo apt-get update && sudo apt-get install r-base r-base-dev -y

# Install latest verion of RStudio Server
sudo apt-get install gdebi-core -y
wget https://www.rstudio.org/download/latest/stable/server/bionic/rstudio-server-latest-amd64.deb
sudo gdebi --non-interactive rstudio-server-latest-amd64.deb
rm rstudio-server-latest-amd64.deb

# Install nginx this will update it if there is a new version
sudo apt-get install nginx -y

# Install latest version of Shiny Server
sudo apt-get install curl -y
VERSION=$(curl https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION)
wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O shiny-server-latest.deb
sudo gdebi -n shiny-server-latest.deb
rm shiny-server-latest.deb

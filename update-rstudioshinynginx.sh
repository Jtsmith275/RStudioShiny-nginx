#!/bin/bash
# Update R/RStudio Server/Shiny Server/nginx on Ubuntu

# Update repository list and install R
sudo apt-get update && sudo apt-get install r-base r-base-dev -y

# Update RStudio Server
sudo apt-get install gdebi-core -y
if [[ $(lsb_release -rs) == "20.04" ]]
then
    wget https://www.rstudio.org/download/latest/stable/server/focal/rstudio-server-latest-amd64.deb  -O rstudio-latest.deb
elif [[ $(lsb_release -rs) == "22.04" ]]
then
    wget https://www.rstudio.org/download/latest/stable/server/jammy/rstudio-server-latest-amd64.deb  -O rstudio-latest.deb
elif [[ $(lsb_release -rs) == "24.04" ]]
then
    wget https://www.rstudio.org/download/latest/stable/server/jammy/rstudio-server-latest-amd64.deb  -O rstudio-latest.deb
else
    echo "Non-compatible version"
fi
sudo gdebi --non-interactive rstudio-latest.deb
rm rstudio-latest.deb

# Update nginx
sudo apt-get install nginx -y

# Update to latest version of Shiny Server
sudo apt-get install curl -y
VERSION=$(curl https://download3.rstudio.org/ubuntu-18.04/x86_64/VERSION)
wget --no-verbose "https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-$VERSION-amd64.deb" -O shiny-server-latest.deb
sudo gdebi -n shiny-server-latest.deb
rm shiny-server-latest.deb

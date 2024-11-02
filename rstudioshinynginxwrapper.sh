#!/bin/bash
# Install R/RStudio Server/Shiny Server/nginx on Ubuntu

# Add repository to APT sources.list
if [[ $(lsb_release -rs) == "20.04" ]]
then
    echo "Ubuntu 20.04 found"
        if grep -Fxq "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" /etc/apt/sources.list
        then
            echo "R repo already in sources.list"
        else
            echo deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/ | sudo tee --append /etc/apt/sources.list
        fi
elif [[ $(lsb_release -rs) == "22.04" ]]
then
    echo "Ubuntu 22.04 found"
        if grep -Fxq "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" /etc/apt/sources.list
        then
            echo "R repo already in sources.list"
        else
            echo deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/ | sudo tee --append /etc/apt/sources.list
        fi
elif [[ $(lsb_release -rs) == "24.04" ]]
then
    echo "Ubuntu 24.04 found"
        if grep -Fxq "deb https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" /etc/apt/sources.list
        then
            echo "R repo already in sources.list"
        else
            echo deb https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/ | sudo tee --append /etc/apt/sources.list
        fi
else
    echo "Non-compatible version"
fi

# Add keys the proper way
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

# Add keys the workaround way (this didn't work when i tried it on 28/10/2024)
# gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
# gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | sudo apt-key add -

# Update repository list and install R
sudo apt-get update && sudo apt-get install r-base r-base-dev -y

# Install RStudio Server
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

# Install nginx
sudo apt-get install nginx -y

# Configure nginx with RStudio Server and Shiny Server virtualhosts
sudo wget https://raw.githubusercontent.com/jb2cool/RStudioShiny-nginx/main/default -O /etc/nginx/sites-enabled/default

# Install Shiny R package
mkdir -p ~/R/x86_64-pc-linux-gnu-library/4.4
R -e "install.packages('shiny', repos='https://cran.rstudio.com/', lib='~/R/x86_64-pc-linux-gnu-library/4.4')"

# Install Shiny Server
sudo apt-get install curl -y
VERSION=$(curl https://download3.rstudio.org/ubuntu-18.04/x86_64/VERSION)
wget --no-verbose "https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-$VERSION-amd64.deb" -O shiny-server-latest.deb
sudo gdebi -n shiny-server-latest.deb
rm shiny-server-latest.deb

# Configure Shiny Server
sudo sed -i "s/run_as shiny/run_as $USER/" /etc/shiny-server/shiny-server.conf
sudo sed -i "s/3838;/ 3838 0.0.0.0;/" /etc/shiny-server/shiny-server.conf
sudo sed -i "s/site_dir \/srv\/shiny-server/site_dir \/home\/$USER\/shiny/" /etc/shiny-server/shiny-server.conf
if grep -q sanitize_errors /etc/shiny-server/shiny-server.conf
then
        echo "Additional Shiny config already completed"
else
    sudo sed -i '/directory_index on;$/a \ \ \ \ sanitize_errors off;\n \ \ \ disable_protocols xdr-streaming xhr-streaming iframe-eventsource iframe-htmlfile;' /etc/shiny-server/shiny-server.conf
fi
mkdir $HOME/shiny

# Copy sample apps to users new Shiny dir
cp -r /opt/shiny-server/samples/sample-apps/hello/ ~/shiny

# Install Jupyterhub and JupyterLab in a virtual environment
sudo apt-get install python3-venv
sudo python3 -m venv /opt/jupyterhub/
sudo /opt/jupyterhub/bin/python3 -m pip install wheel
sudo /opt/jupyterhub/bin/python3 -m pip install jupyterhub jupyterlab
sudo /opt/jupyterhub/bin/python3 -m pip install ipywidgets
sudo apt install nodejs npm
sudo npm install -g configurable-http-proxy

# Create the configuration for JupyterHub
sudo mkdir -p /opt/jupyterhub/etc/jupyterhub/
#cd /opt/jupyterhub/etc/jupyterhub/
sudo /opt/jupyterhub/bin/jupyterhub --generate-config
sudo cp jupyterhub_config.py /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py
sudo sed -i "s|# c.Spawner.default_url = ''|c.Spawner.default_url = '/lab'|" /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py
sudo sed -i "s|# c.JupyterHub.bind_url = 'http://:8000'|c.JupyterHub.bind_url = 'http://:8000/jupyter'|" /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py

# Setup Systemd service
sudo mkdir -p /opt/jupyterhub/etc/systemd
sudo cp https://raw.githubusercontent.com/jtsmith275/RStudioShiny-nginx/master/jupyterhub.service /opt/jupyterhub/etc/systemd/jupyterhub.service
sudo ln -s /opt/jupyterhub/etc/systemd/jupyterhub.service /etc/systemd/system/jupyterhub.service
sudo systemctl daemon-reload
sudo systemctl enable jupyterhub.service
sudo systemctl start jupyterhub.service

# Conda environments
# Install conda for the whole system
curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg
sudo install -o root -g root -m 644 conda.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" | sudo tee /etc/apt/sources.list.d/conda.list
sudo apt update
sudo apt install conda
sudo ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh

# Install a default conda environment for all users
sudo mkdir /opt/conda/envs/
sudo /opt/conda/bin/conda create --prefix /opt/conda/envs/python python=3.7 ipykernel
sudo /opt/conda/envs/python/bin/python -m ipykernel install --prefix=/opt/jupyterhub/ --name 'python' --display-name "Python (default)"

# Restart services
sudo systemctl restart nginx
sudo systemctl enable nginx
sudo systemctl restart shiny-server
sudo systemctl restart jupyter.service

#Tell user everything works
echo "nginx is now hosting a webpage on http://127.0.0.1"
echo "RStudio Server is now available on http://127.0.0.1:8787 & http://127.0.0.1/rstudio"
echo "Shiny Server is now available on http://127.0.0.1:3838 & http://127.0.0.1/shiny"
echo "Jupyterhub is now available on http://127.0.0.1:8000 & http://127.0.0.1/jupyter"

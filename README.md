# RStudioShiny-nginx

1. git clone https://github.com/Jtsmith275/RStudioShiny-nginx  
1. cd RStudioShiny-nginx  
1. sudo chmod +x rstudioshinynginxwrapper.sh  
1. enter SCE password when prompted  
1. ./rstudioshinynginxwrapper.sh  
1. enter SCE password when prompted  
1. request intranet hosting on the SCE see https://defra.sharepoint.com/teams/Team741/SitePages/Services.aspx#internal-and-external-hosting  

# For JupyterHub:

IF USING ANACONDA FROM GOVERNMENT OR COMMERICAL USE PLEASE ENSURE YOU HAVE A COMMERICAL LICENSE  

1. Follow steps above for RStudio-Server and Shiny-Server
2. Using the terminal (easiest done in JupyterHub using the launcher), create a conda environment using *conda create -n geospatial* replacing *geospatial* with what you want to call the environment.
3. Activate the environment using *conda activate geospatial*
4. Install packages using *conda install name-of-package* replacing *name-of-package* with the name of the package(s) you want to install. Refer to the package-specific documentation for package-specific instructions.
5. Install the ipykernel package using *conda install ipykernel*, this package is required to create kernels in JupyterHub that use a specific conda environment as default.
6. Run *python3 -m ipykernel install --user --name this-is-my-kernel* replacing *this-is-my-kernel* with a name that does not have to match the name of the conda environment **exactly**, but its sensible to maintain a distinct theme/naming convention to avoid confusion down the line. I.e. not knowing which conda environments are used for which kernels.
7. Open a Jupyter notebook from JupyterHub using the icon with the name you have just defined in step 6 and import packages from the environment as usual.

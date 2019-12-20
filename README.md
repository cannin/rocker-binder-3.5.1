# AWS Lightsail Instructions for rocker/binder Based TargetScore

# Install Docker
```
# Non-interactive mode installation
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt install -y docker.io python3-pip git

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# Install repo2docker
sudo python3 -m pip install https://github.com/jupyter/repo2docker/archive/master.zip

# Make user because repo2docker connects real user to Docker guest user
sudo adduser rstudio --disabled-password --gecos "" --uid 123
```

# Create Docker image
```
git clone https://github.com/cannin/rocker-binder-3.5.1.git
cd rocker-binder-3.5.1
sudo jupyter-repo2docker --user-id 123 --user-name rstudio --image-name cannin/targetscore:mcl1-analysis .
```

# Grab TargetScore specific code for installation within Docker
```
git clone https://cannin@bitbucket.org/cbio_mskcc/zeptosenspkg.git
cd zeptosenspkg
git checkout d893ecba4690f9d181b9070c5e00bc83983beb14 -b mcl1-analysis

cp -R zeptosenspkg/zeptosensPkg/ rocker-binder-3.5.1/
cp -R zeptosenspkg/zeptosensUtils/ rocker-binder-3.5.1/
```

# Commands for saving manual in-guest changes to image
```
sudo docker commit d720ecd1dedc cannin/targetscore:mcl1-analysis
sudo docker push cannin/targetscore:mcl1-analysis
sudo docker run -d cannin/targetscore:mcl1-analysis
```

# Run Docker
```
docker rm -f ts; docker run --name ts -p 8888:8888 -it cannin/targetscore:mcl1-analysis
```

#!/bin/bash
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo "Running initializer for ${machine}"

echo "Do you want to download the pretrained model and data? (y/n)"
read answer
if test "$answer" == "y"; then
    echo "Downloading data ..."
    # wget https://github.com/HanHan55/Graph2plan/releases/download/data/Data.zip
    unzip data.zip -d data
    rm data.zip
    echo "Data downloaded!"
else
    echo "Skipping data download ..."
fi

ENV_DIR="$PWD/.env"
if test -d "$ENV_DIR"; then
    echo "Conda environment exists under .env!"
else
    conda create --prefix .env python=3.11
fi

eval "$(conda shell.zsh hook)"
conda activate ./.env
if test "$ENV_DIR" == "$CONDA_PREFIX"; then
    echo "Active environment: $CONDA_PREFIX"
    echo "Installing necessary packages ..."
    conda install pip
    if test "${machine}" == "Mac"; then
        echo "This is a Mac device"
    else
        echo "This is a Linux device"
    fi
    echo "You have to run the following commands manually:"
    echo "sudo apt-get install build-essential python-dev libagg-dev libpotrace-dev pkg-config graphviz libgraphviz-dev"
    echo "Have your run them yet? (y/n)"
    read answer
    if test "$answer" == "y"; then
        echo "Installing packages ..."
    else
        echo "Please run the commands and try again"
        exit 1
    fi
    python -m pip install -r requirements.txt
    python -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118

else
    echo "Couldn't activate: $ENV_DIR"
fi
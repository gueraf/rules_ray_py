# rules_ray_py

# Setup
```shell
sudo apt install pipx zstd

curl -fsSL https://pyenv.run | bash

wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -O /tmp/miniconda.sh && \
chmod +x /tmp/miniconda.sh && \
/tmp/miniconda.sh -b && \
rm /tmp/miniconda.sh && \
bash -c "source ~/miniconda3/bin/activate && \
true || ~/miniconda3/bin/conda init --all && \
~/miniconda3/bin/conda config --add channels conda-forge && \
~/miniconda3/bin/conda install -n base conda-package-handling>=2.4.0 conda-build"

sudo apt install build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev curl git \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
~/.pyenv/bin/pyenv install 3.13.2

pipx install ray[default]==2.45.0 --python ~/.pyenv/versions/3.13.2/bin/python
```

# Start a local ray cluster (for testing)
```shell
ray start --head
# Dashboard: 127.0.0.1:8265
```

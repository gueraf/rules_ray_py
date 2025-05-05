# rules_ray_py

# Setup
```shell
sudo apt install pipx zstd

wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -O /tmp/miniconda.sh && \
chmod +x /tmp/miniconda.sh && \
/tmp/miniconda.sh -b && \
rm /tmp/miniconda.sh && \
bash -c "source ~/miniconda3/bin/activate && \
true || ~/miniconda3/bin/conda init --all && \
~/miniconda3/bin/conda config --add channels conda-forge && \
~/miniconda3/bin/conda install -n base conda-package-handling>=2.4.0 conda-build"

pipx install ray[default]==2.45.0
```

# Start a local ray cluster (for testing)
```shell
ray start --head --port 6379
# Dashboard: 127.0.0.1:8265
```

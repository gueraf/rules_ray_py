# rules_ray_py

Work in progress, super hacky and likely never stable!

# Core Idea
- Use Bazel to build python applications (incl. pip dependency management); see e.g. https://github.com/gueraf/template_py.
- Wrap a `py_binary` into `@rules_ray_py//rules_ray_py:ray_job` to
  - Create a self-extracting conda capturing all dependencies.
  - Copy the package to a NFS share that all ray workers can access.
  - Use a (system-provided) ray cli to submit a job to a (remote) ray cluster such that the package is installed, and the application is started with correct PYTHONPATH set, etc.

# Quickstart
## Step 1: MODULE.bazel
```python
# ...
bazel_dep(name = "rules_ray_py", version = "0.0.0")
git_override(
    module_name = "rules_ray_py",
    commit = "61287dda0221426649458d363f79ae7be1f46976",
    remote = "https://github.com/gueraf/rules_ray_py.git",
)
# ...
```

## Step 2: main.py
```python
import os
import ray
import fancy_lib

@ray.remote
def use_fancy_lib():
    return fancy_lib.magic_string

def main():
    ray.init(
        runtime_env={
            "env_vars": {
                "PYTHONPATH": os.path.dirname(os.path.realpath(__file__)).split(
                    "/site-packages/", 1
                )[0]
                + "/site-packages/site-packages/"
            },
        }
    )
    print(ray.get(use_fancy_lib.remote()))

if __name__ == "__main__":
    main()
```

## STEP 3: BUILD.bazel
```python
load("@aspect_rules_py//py:defs.bzl", "py_binary")
load("@rules_ray_py//rules_ray_py:defs.bzl", "ray_job")

py_binary(
    name = "main",
    srcs = ["main.py"],
    deps = ["@pip//ray",],
)

# Setup: pipx install ray[default]==x.yy.z
ray_job(
    name = "main_ray_job",
    wrapped_py_binary = ":main",
    # Must be visible to build machine and all workers.
    nfs_packages_folder = "/mnt/nfs/ray_bin/",
    # TODO: Change for your cluster.
    ray_cluster_address = "http://127.0.0.1:8265",
)
```

## STEP 4: Run
```shell
bazel run //:main_ray_job -- --flag_for_main=foo --another_flag=bar
```

See https://github.com/gueraf/rules_ray_py_test/tree/main/examples for full e2e examples.

[![CircleCI](https://dl.circleci.com/status-badge/img/circleci/MoqoviNBD61M3rSAe4Bj3m/c413fc66-be8a-4ba6-8342-20cf96148e9c/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/circleci/MoqoviNBD61M3rSAe4Bj3m/c413fc66-be8a-4ba6-8342-20cf96148e9c/tree/main)

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
# TODO: Adjust python version for your cluster.
~/.pyenv/bin/pyenv install 3.12.3

# TODO: Adjust ray and python version for your cluster.
pipx install ray[default]==2.45.0 --python ~/.pyenv/versions/3.12.3/bin/python
```

# Start a local ray cluster (for testing)
```shell
export RAY_CONDA_HOME=$(realpath ~/miniconda3/) && ray start --head
# Dashboard: 127.0.0.1:8265
```

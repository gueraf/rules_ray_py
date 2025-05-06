import argparse
import json
import os
import shutil
import uuid


def make_conda_index(conda_bin_path: str, package_folder: str, input_conda: str):
    os.makedirs(os.path.join(package_folder, "linux-64"), exist_ok=True)
    shutil.copy(
        input_conda, os.path.join(package_folder, "linux-64", "bazel_package-0.0.0-0.conda")
    )
    conda_index_cmd = f"{conda_bin_path} index {package_folder}"
    result = os.system(conda_index_cmd)
    if result != 0:
        raise RuntimeError(f"Conda index failed with status {result}")


def submit_job(
    ray_bin_path: str,
    ray_cluster_address: str,
    package_folder: str,
):
    # https://docs.ray.io/en/latest/ray-core/handling-dependencies.html#specifying-a-runtime-environment-per-job
    runtime_env = {
        "conda": {
            "channels": ["file://" + package_folder],
            "dependencies": [
                # package_name,
                # TODO: Reconsider hardcoded package name.
                "bazel_package",
            ],
        },
        # "env_vars": {},
    }
    entrypoint = " && ".join(
        [
            # # "which python3",
            # # "export FOO=bar",
            # # "echo FOO = $FOO",
            # # "FOO=bar echo $FOO",
            # "export PYTHON_BIN_PATH=\\$(which python3)",
            # "echo PYTHON_BIN_PATH = \\$PYTHON_BIN_PATH",
            # # 'python3 --version | grep -oP "3\\.\\d+"',
            # 'export PYTHON_VERSION=\\$(python3 --version | grep -oP "3\\.\\d+")',
            # "echo PYTHON_VERSION = \\$PYTHON_VERSION",
            # # 'which python3 | sed "s:/bin/python3::"',
            # "export BASE_PATH=\\$(which python3 | sed 's:/bin/python3:/lib/python$PYTHON_VERSION/:')",
            # "echo BASE_PATH=\\$BASE_PATH",
            # "export PYTHONPATH=\\$BASE_DIR/:$BASE_PATH/site-packages/",
            "python3 -c 'import sys; print(sys.path)'",
            "python3 -c 'import absl; print(absl.__file__)'",
        ]
    )
    ray_submit_cmd = (
        f"{ray_bin_path} job submit "
        + f"--address={ray_cluster_address} "
        + f"--runtime-env-json='{json.dumps(runtime_env)}' "
        + f'-- /bin/bash -c "{entrypoint}"'
    )
    result = os.system(ray_submit_cmd)
    if result != 0:
        raise RuntimeError(f"Ray submission failed with status {result}")


def main():
    parser = argparse.ArgumentParser(description="Submits a conda package to a remote ray cluster.")
    parser.add_argument("--nfs_packages_folder", required=True, help="Path to NFS packages folder")
    parser.add_argument("--input_conda", required=True, help="Path to input conda package")
    parser.add_argument("--ray_cluster_address", default="auto", help="Ray cluster address. ")
    # TODO: Maybe also use RAY_ADDRESS env variable.
    parser.add_argument(
        "--conda_bin_path",
        required=True,
        help="Path to conda binary.",
    )
    parser.add_argument(
        "--ray_bin_path",
        required=True,
        help="Path to ray cli binary.",
    )
    args = parser.parse_args()

    package_folder = os.path.join(args.nfs_packages_folder, uuid.uuid4().hex)

    make_conda_index(
        conda_bin_path=args.conda_bin_path,
        package_folder=package_folder,
        input_conda=args.input_conda,
    )
    submit_job(
        ray_bin_path=args.ray_bin_path,
        ray_cluster_address=args.ray_cluster_address,
        package_folder=package_folder,
    )

    # TODO: Add feature to (not) keep following the job logs. Add --no-wait to command.


if __name__ == "__main__":
    main()

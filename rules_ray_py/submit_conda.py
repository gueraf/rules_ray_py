import argparse
import json
import os
import uuid


def make_conda_index(conda_bin_path: str, package_folder: str):
    conda_index_cmd = f"{conda_bin_path} index {package_folder}"
    result = os.system(conda_index_cmd)
    if result != 0:
        raise RuntimeError(f"Conda index failed with status {result}")


def submit_job(ray_bin_path: str, ray_cluster_address: str, package_folder: str, package_name: str):
    # https://docs.ray.io/en/latest/ray-core/handling-dependencies.html#specifying-a-runtime-environment-per-job
    runtime_env = {
        "conda": {
            "channels": ["file://" + package_folder],
            "dependencies": [
                package_name,
            ],
        },
        "env_vars": {},
    }
    entrypoint = "; ".join(
        [
            "which python3",
        ]
    )
    ray_submit_cmd = (
        f"{ray_bin_path} job submit "
        + f"--address={ray_cluster_address} "
        + f"--runtime-env-json='{json.dumps(runtime_env)}' "
        + f"-- {entrypoint}"
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
    os.makedirs(package_folder, exist_ok=True)

    make_conda_index(
        conda_bin_path=args.conda_bin_path,
        package_folder=package_folder,
    )
    submit_job(
        ray_bin_path=args.ray_bin_path,
        ray_cluster_address=args.ray_cluster_address,
        package_folder=package_folder,
        package_name=os.path.basename(args.input_conda).split("-")[0],
    )

    # TODO: Add feature to (not) keep following the job logs.


if __name__ == "__main__":
    main()

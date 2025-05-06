load("py_conda.bzl", "py_conda")
load("@aspect_rules_py//py:defs.bzl", "py_binary")


def ray_job(
    name,
    wrapped_py_binary,
    args=[],
    nfs_packages_folder="/tmp",
    conda_bin_path="~/miniconda3/bin/conda",
    ray_bin_path="~/.local/bin/ray",
    ray_cluster_address="http://127.0.0.1:8265",
):
    py_conda(
        name=name + "_ray_job_conda",
        wrapped_py_binary=wrapped_py_binary,
        conda_bin_path=conda_bin_path,
    )

    native.genrule(
        name=name + "_ray_cli",
        srcs=[],
        outs=[name + "_ray_cli"],
        cmd="ls " + ray_bin_path + "| xargs -I {} ln -s {} $@",
    )

    py_binary(
        name=name,
        srcs=["@rules_ray_py//rules_ray_py:submit_conda.py"],
        data=[
            name + "_ray_job_conda",
            name + "_ray_job_conda_conda_cli",
            name + "_ray_cli",
        ],
        args=args
        + [
            "--nfs_packages_folder=" + nfs_packages_folder,
            "--input_conda=$(location " + name + "_ray_job_conda)",
            "--ray_bin_path=$(location " + name + "_ray_cli)",
            "--conda_bin_path=$(location " + name + "_ray_job_conda_conda_cli)",
            "--ray_cluster_address=" + ray_cluster_address,
        ],
    )

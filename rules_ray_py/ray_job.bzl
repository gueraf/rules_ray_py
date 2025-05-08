load("@aspect_rules_py//py:defs.bzl", "py_binary")
load("py_conda.bzl", "py_conda")

def ray_cli_symlink(name, ray_bin_path = None):
    known_ray_bin_paths = [
        "~/.local/bin/ray",
        "~/anaconda3/bin/ray",
    ]
    if ray_bin_path != None:
        known_ray_bin_paths = [ray_bin_path]
    native.genrule(
        name = name,
        srcs = [],
        outs = [name],
        # Filter down known_ray_bin_paths to first existing one and set symlink.
        # TODO: Debug why || true is needed.
        cmd = "ls -d -1 " + " ".join(known_ray_bin_paths) + " 2>/dev/null | head -n 1 | xargs -I {} ln -s {} $@ || true",
    )

def ray_job(
        name,
        wrapped_py_binary,
        args = [],
        nfs_packages_folder = "/tmp",
        conda_bin_path = None,
        ray_bin_path = None,
        ray_cluster_address = "http://127.0.0.1:8265"):
    py_conda(
        name = name + "_ray_job_conda",
        wrapped_py_binary = wrapped_py_binary,
        conda_bin_path = conda_bin_path,
    )

    ray_cli_symlink(name = name + "_ray_cli", ray_bin_path = ray_bin_path)

    py_binary(
        name = name,
        srcs = ["@rules_ray_py//rules_ray_py:submit_conda.py"],
        data = [
            name + "_ray_job_conda",
            name + "_ray_job_conda_conda_cli",
            name + "_ray_cli",
        ],
        args = args +
               [
                   "--nfs_packages_folder=" + nfs_packages_folder,
                   "--input_conda=$(location " + name + "_ray_job_conda)",
                   # TODO: This is a strong assumption. We should use the actual name of the file.
                   "--input_entrypoint_file=" +
                   native.package_name() +
                   "/" +
                   Label(wrapped_py_binary).name +
                   ".py",
                   "--ray_bin_path=$(location " + name + "_ray_cli)",
                   "--conda_bin_path=$(location " + name + "_ray_job_conda_conda_cli)",
                   "--ray_cluster_address=" + ray_cluster_address,
               ],
    )

load("py_tar_zst.bzl", "py_tar_zst")

def conda_bin_symlink(name, conda_bin_path = None):
    known_conda_bin_paths = [
        "~/miniconda3/bin/conda",
        "~/anaconda3/bin/conda",
    ]
    if conda_bin_path != None:
        known_conda_bin_paths = [conda_bin_path]
    native.genrule(
        name = name,
        srcs = [],
        outs = [name],
        # Filter down known_conda_bin_paths to first existing one and set symlink.
        # TODO: Debug why || true is needed.
        cmd = "ls -d -1 " + " ".join(known_conda_bin_paths) + " 2>/dev/null | head -n 1 | xargs -I {} ln -s {} $@ || true",
    )

def py_conda(name, wrapped_py_binary, conda_bin_path = None):
    py_tar_zst(name = name + "_py_tar_zst", wrapped_py_binary = wrapped_py_binary)

    conda_bin_symlink(name = name + "_conda_cli", conda_bin_path = conda_bin_path)

    native.genrule(
        name = name,
        srcs = [
            name + "_py_tar_zst.tar.zst",
            name + "_conda_cli",
        ],
        outs = [name + ".conda"],
        cmd = "$(location @rules_ray_py//rules_ray_py:tar_to_conda) --conda_bin_path=$(location " +
              name +
              "_conda_cli) --input_tar_zst=$(location " +
              name +
              "_py_tar_zst.tar.zst) --output_conda=$(location " +
              name +
              ".conda)",
        tools = ["@rules_ray_py//rules_ray_py:tar_to_conda"],
        # Note: Sandboxing doesn't work due to https://github.com/conda/conda-build/issues/3161 :(
        local = True,
    )

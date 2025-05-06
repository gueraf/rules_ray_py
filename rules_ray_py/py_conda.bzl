load("py_tar_zst.bzl", "py_tar_zst")


def py_conda(name, wrapped_py_binary, conda_bin_path="~/miniconda3/bin/conda"):
    py_tar_zst(name=name + "_py_tar_zst", wrapped_py_binary=wrapped_py_binary)

    native.genrule(
        name=name + "_conda_cli",
        srcs=[],
        outs=[name + "_conda_cli"],
        cmd="ls " + conda_bin_path + "| xargs -I {} ln -s {} $@",
    )

    native.genrule(
        name=name,
        srcs=[
            name + "_py_tar_zst.tar.zst",
            name + "_conda_cli",
        ],
        outs=[name + ".conda"],
        cmd="$(location @rules_ray_py//rules_ray_py:tar_to_conda) --conda_bin_path=$(location "
        + name
        + "_conda_cli) --input_tar_zst=$(location "
        + name
        + "_py_tar_zst.tar.zst) --output_conda=$(location "
        + name
        + ".conda)",
        tools=["@rules_ray_py//rules_ray_py:tar_to_conda"],
        # Note: Sandboxing doesn't work due to https://github.com/conda/conda-build/issues/3161 :(
        local=True,
    )

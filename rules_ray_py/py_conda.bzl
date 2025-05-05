load("py_tar_zst.bzl", "py_tar_zst")
load("@bazel_skylib//rules:run_binary.bzl", "run_binary")


def py_conda(name, wrapped_py_binary, conda_bin_path="~/miniconda3/bin/conda"):
    py_tar_zst(name=name + "_py_tar_zst", wrapped_py_binary=wrapped_py_binary)

    native.genrule(
        name="conda_cli",
        srcs=[],
        outs=["conda_cli"],
        cmd="ls " + conda_bin_path + "| xargs -I {} ln -s {} $@",
    )

    run_binary(
        name=name,
        srcs=[
            name + "_py_tar_zst.tar.zst",
            "conda_cli",
        ],
        outs=[name + ".conda"],
        tool="@rules_ray_py//rules_ray_py:tar_to_conda",
        args=[
            "--conda_bin_path=$(location conda_cli)",
            "--input_tar_zst=$(location " + name + "_py_tar_zst.tar.zst)",
            "--output_conda=$(location " + name + ".conda)",
        ],
    )

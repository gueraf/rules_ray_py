load("py_tar_zst.bzl", "py_tar_zst")
load("@bazel_skylib//rules:run_binary.bzl", "run_binary")


def py_conda(name, wrapped_py_binary):
    py_tar_zst(name=name + "_py_tar_zst", wrapped_py_binary=wrapped_py_binary)

    run_binary(
        name=name,
        srcs=[name + "_py_tar_zst.tar.zst"],
        outs=[name + ".conda"],
        tool="@rules_ray_py//rules_ray_py:tar_to_conda",
        args=[
            "--input_tar_zst=$(location " + name + "_py_tar_zst.tar.zst)",
            "--output_conda=$(location " + name + ".conda)",
        ],
    )

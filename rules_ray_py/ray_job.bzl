load("@aspect_rules_py//py:defs.bzl", "py_binary")
load("@rules_python//python:packaging.bzl", "py_package")
load("py_tar_zst.bzl", "py_tar_zst")


# genrule(
#     name = "concat_all_files",
#     srcs = [
#         "//some:files",  # a filegroup with multiple files in it ==> $(locations)
#         "//other:gen",   # a genrule with a single output ==> $(location)
#     ],
#     outs = ["concatenated.txt"],
#     cmd = "cat $(locations //some:files) $(location //other:gen) > $@",
# )


def _demo_binary_impl(ctx):
    out = ctx.actions.declare_file("hello")
    cmd = ["#!/bin/sh", 'echo "Hello, World!"']
    ctx.actions.write(
        output=out,
        content="\n".join(cmd),
    )
    return [
        DefaultInfo(
            files=depset([out]),
            executable=out,
        )
    ]


demo_binary = rule(
    implementation=_demo_binary_impl,
    executable=True,
)


def ray_job(
    name,
    wrapped_py_binary,
):
    py_tar_zst(name=name + "_py_tar_zst", wrapped_py_binary=wrapped_py_binary)

    demo_binary(name=name)

load("py_conda.bzl", "py_conda")


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
    py_conda(name=name + "_ray_job_conda", wrapped_py_binary=wrapped_py_binary)

    demo_binary(name=name)

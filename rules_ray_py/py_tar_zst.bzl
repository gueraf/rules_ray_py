def _py_package_file_list_impl(ctx):
    inputs_to_package = depset(
        direct = ctx.files.deps,
    )
    packageinputfile = ctx.actions.declare_file(ctx.attr.name + ".txt")
    content = ""
    for input_file in inputs_to_package.to_list():
        content += input_file.path + "\n"
    ctx.actions.write(output = packageinputfile, content = content)

    return [DefaultInfo(files = depset([packageinputfile]))]

_py_package_file_list = rule(
    implementation = _py_package_file_list_impl,
    attrs = {
        "deps": attr.label_list(
            doc = "The dependencies to package into the tar.zst file.",
        ),
    },
)

def py_tar_zst(name, wrapped_py_package, transforms = ["s,^external/[^/]\\+/,,", "s,^bazel-out/k8-fastbuild/bin/,,"]):
    file_list_name = name + ".file_list"
    _py_package_file_list(
        name = file_list_name,
        deps = [wrapped_py_package],
    )

    tar_cmd_str = "tar --create --dereference --mtime='UTC 2019-01-01' -I pzstd -T $(location :" + file_list_name + ") --file=$(OUTS)"
    for transform in transforms:
        tar_cmd_str += " --transform='" + transform + "'"
    native.genrule(
        name = name,
        srcs = [
            ":" + file_list_name,
            wrapped_py_package,
        ],
        outs = [name + ".tar.zst"],
        cmd = tar_cmd_str,
        output_to_bindir = 1,
    )

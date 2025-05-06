load("@aspect_rules_py//py:defs.bzl", "py_binary")

py_binary(
    name = "tar_to_conda",
    srcs = ["tar_to_conda.py"],
    visibility = ["//visibility:public"],
)

py_binary(
    name = "submit_conda",
    srcs = ["submit_conda.py"],
    visibility = ["//visibility:public"],
)

exports_files(
    ["submit_conda.py"],
    visibility = ["//visibility:public"],
)

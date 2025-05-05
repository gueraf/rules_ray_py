import argparse
import os
import shutil
import string
import tempfile

# TODO: Don't hardcode package name.
META_YAML = """
package:
  name: bazel_package
  version: '0.0.0'
source:
  path: .
output:
  - name: bazel_package
    type: conda_v2
    build:
      number: 0
      linux-64: generic
"""


def write_meta_yaml(tmp_dir: str):
    meta_yaml_path = os.path.join(tmp_dir, "meta.yaml")
    with open(meta_yaml_path, "w") as f:
        f.write(META_YAML)


BUILD_SH = string.Template(
    """#!/bin/bash
mkdir -p $$PREFIX/lib/$PYTHON_VERSION_STRING/
mv $$RECIPE_DIR/*.tar.zst $$PREFIX/lib/$PYTHON_VERSION_STRING/
"""
)


def write_build_sh(tmp_dir: str, python_version_string: str):
    build_sh_path = os.path.join(tmp_dir, "build.sh")
    with open(build_sh_path, "w") as f:
        f.write(BUILD_SH.substitute(PYTHON_VERSION_STRING=python_version_string))
    os.chmod(build_sh_path, 0o755)


POST_LINK_SH = string.Template(
    """
#!/bin/bash
tar -xf $$PREFIX/lib/$PYTHON_VERSION_STRING/*.tar.zst -C $$PREFIX/lib/$PYTHON_VERSION_STRING/
rm $$PREFIX/lib/$PYTHON_VERSION_STRING/*.tar.zst
"""
)


def write_post_link_sh(tmp_dir: str, python_version_string: str):
    post_link_sh_path = os.path.join(tmp_dir, "post-link.sh")
    with open(post_link_sh_path, "w") as f:
        f.write(POST_LINK_SH.substitute(PYTHON_VERSION_STRING=python_version_string))
    os.chmod(post_link_sh_path, 0o755)


CONDARC = """
conda_build:
  pkg_format: 2
  zstd_compression_level: 1
  force_zip64: True
"""


def write_condarc(tmp_dir: str):
    condarc_path = os.path.join(tmp_dir, ".condarc")
    with open(condarc_path, "w") as f:
        f.write(CONDARC)


def convert_package(
    input_tar_zst: str,
    output_conda: str,
    tmp_dir: str,
    python_version_string: str,
):
    shutil.copy(input_tar_zst, tmp_dir)

    write_meta_yaml(tmp_dir)
    write_build_sh(tmp_dir, python_version_string=python_version_string)
    write_post_link_sh(tmp_dir, python_version_string=python_version_string)
    write_condarc(tmp_dir)

    # Simulate writing a file to the temporary directory
    with open("foo.txt", "w") as f:
        pass

    # Create an empty file at the output location
    with open(output_conda, "w") as f:
        pass


def main():
    parser = argparse.ArgumentParser(description="Convert tar.zst file to conda package")
    parser.add_argument("--input_tar_zst", required=True, help="Path to input tar.zst file")
    parser.add_argument("--output_conda", required=True, help="Path to output conda package")
    parser.add_argument(
        "--python_version_string",
        default="python3.12",
        help="Python version string. Defaults to 'python3.12'.",
    )
    args = parser.parse_args()

    with tempfile.TemporaryDirectory() as temp_dir:
        convert_package(
            args.input_tar_zst,
            args.output_conda,
            temp_dir,
            python_version_string=args.python_version_string,
        )


if __name__ == "__main__":
    main()

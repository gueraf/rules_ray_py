import argparse
import tempfile


def convert_package(input_tar_zst: str, output_conda: str, tmp_dir: str):
    # TODO: Implement conversion logic.

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
    args = parser.parse_args()

    # Use args.input_tar_zst and args.output_conda here
    print(f"Input tar.zst: {args.input_tar_zst}")
    print(f"Output conda: {args.output_conda}")

    with tempfile.TemporaryDirectory() as temp_dir:
        convert_package(args.input_tar_zst, args.output_conda, temp_dir)


if __name__ == "__main__":
    main()

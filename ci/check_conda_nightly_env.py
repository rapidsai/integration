# Copyright (c) 2024-2025, NVIDIA CORPORATION.
import json
import re
import sys
from datetime import datetime, timedelta


OLD_PACKAGE_THRESHOLD_DAYS = 3

EXCLUDED_PACKAGES = {
    # These packages are not built every night:
    "rapids",
    "rapids-xgboost",
    # These packages do not have date strings:
    "rapids-dask-dependency",
    "rapids-logger",  # Also not built every night
    "libxgboost",
    "py-xgboost",
    "xgboost",
}

# ANSI color codes used to highlight lines
FAIL = "\033[31m"
WARNING = "\033[33m"
OKGREEN = "\033[32m"
ENDC = "\033[0m"


def is_rapids_nightly_package(package_info):
    return package_info["channel"] == "rapidsai-nightly"


def get_package_date(package):
    if package["name"] in EXCLUDED_PACKAGES:
        return None

    # Matches 6 digits starting with "2", which should be YYMMDD
    date_re = r"(?:^|_)(2\d{5})_"

    # Use regex to find the date string in the input
    match = re.search(date_re, package["build_string"])

    if match:
        # Convert the date string to a datetime object
        date_string = match.group(1)
        date_object = datetime.strptime(date_string, "%y%m%d")
        return date_object

    print(
        f"{WARNING}Date string not found for {package['name']} "
        f"in the build string '{package['build_string']}'.{ENDC}"
    )


def check_env(json_path):
    """Validate rapids conda environments.

    Parses JSON output of `conda create` and check the dates on the RAPIDS
    packages to ensure nightlies are relatively new.

    Returns an exit code value.
    """

    exit_code = 0

    with open(json_path) as f:
        try:
            json_data = json.load(f)
        except ValueError as e:
            print("Error: JSON data file from conda failed to load:")
            print(e)
            return 1

    if "error" in json_data:
        print("Error: conda failed:")
        print()
        print(json_data["error"])
        return 1

    package_data = json_data["actions"]["LINK"]

    rapids_package_data = list(filter(is_rapids_nightly_package, package_data))

    # Dictionary to store the packages and their dates
    rapids_package_dates = {
        package["name"]: get_package_date(package) for package in rapids_package_data
    }

    # If there are old packages, show an error
    today = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    old_threshold = today - timedelta(days=OLD_PACKAGE_THRESHOLD_DAYS)
    old_packages = {
        package: date
        for package, date in rapids_package_dates.items()
        if date is not None and date < old_threshold
    }
    if old_packages:
        exit_code = 1
        print()
        print(
            f"{FAIL}Error: The following packages are more than "
            f"{OLD_PACKAGE_THRESHOLD_DAYS} days old:{ENDC}"
        )
        for package, date in sorted(old_packages.items()):
            date_string = date.strftime("%Y-%m-%d")
            print(f"{FAIL} - {(package + ':'):<24}\t{date_string}{ENDC}")

    # If there are undated packages, show an error
    undated_packages = {
        package: date
        for package, date in rapids_package_dates.items()
        if package not in EXCLUDED_PACKAGES and date is None
    }
    if undated_packages:
        exit_code = 1
        print()
        print(
            f"{FAIL}Error: The following packages are missing dates in their "
            f"build strings:{ENDC}"
        )
        for package, date in sorted(undated_packages.items()):
            print(f"{FAIL} - {package}{ENDC}")

    print()
    print(
        f"The following packages are less than {OLD_PACKAGE_THRESHOLD_DAYS} days old:"
    )
    for package, date in sorted(rapids_package_dates.items()):
        if date is None:
            continue
        date_string = date.strftime("%Y-%m-%d")
        status = WARNING if date < today else OKGREEN
        print(f"{status} - {(package + ':'):<24}\t{date_string}{ENDC}")

    return exit_code


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Provide only one argument, the filepath to a JSON output from conda.")
        sys.exit(1)

    sys.exit(check_env(sys.argv[1]))

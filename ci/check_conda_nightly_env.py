import json
import re
import subprocess
import sys
from datetime import datetime, timedelta


OLD_PACKAGE_THRESHOLD_DAYS = 3


def is_rapids_nightly_package(package_info):
    return package_info["channel"] == "rapidsai-nightly"


def get_package_date(package):
    date_re = re.compile(r"(2\d{5})")

    # 2\d{5} matches 6 digits starting with "2"
    date_re = r"_(2\d{5})_"

    # Use regex to find the date string in the input
    match = re.search(date_re, package["build_string"])

    if match:
        # Convert the date string to a datetime object
        date_string = match.group(1)
        date_object = datetime.strptime(date_string, "%y%m%d")
        return date_object

    print(
        f"Date string not found for {package['name']} "
        f"in the build string '{package['build_string']}'."
    )
    return None


def check_env(json_path):
    """Validate rapids conda environments.

    Parses JSON output of `conda create` and check the dates on the RAPIDS
    packages to ensure nightlies are relatively new.
    """

    with open(json_path) as f:
        try:
            json_data = json.load(f)
        except ValueError as e:
            print("Error: JSON data file from conda failed to load:")
            print(e)
            sys.exit(1)

    if "error" in json_data:
        print("Error: conda failed:")
        print()
        print(json_data["error"])
        sys.exit(1)

    package_data = json_data["actions"]["LINK"]

    rapids_package_data = list(filter(is_rapids_nightly_package, package_data))

    # Dictionary to store the packages and their dates
    rapids_package_dates = {
        package["name"]: get_package_date(package)
        for package in rapids_package_data
    }

    old_threshold = datetime.now() - timedelta(days=OLD_PACKAGE_THRESHOLD_DAYS)
    old_packages = {
        package: date
        for package, date in rapids_package_dates.items()
        if date is not None and date < old_threshold
    }

    # If there are old packages, raise an error
    if old_packages:
        print()
        print(
            "Error: The following nightly packages are more than "
            f"{OLD_PACKAGE_THRESHOLD_DAYS} days old:"
        )
        for package, date in old_packages.items():
            date_string = date.strftime("%Y-%m-%d")
            print(f" - {package}: {date_string}")
        sys.exit(1)

    print(f"All packages are less than {OLD_PACKAGE_THRESHOLD_DAYS} days old.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(
            "Provide only one argument, the filepath to a JSON output from "
            "conda."
        )
        sys.exit(1)

    check_env(sys.argv[1])

# integration
RAPIDS - combined conda package &amp; integration tests for all of RAPIDS libraries

The conda recipe in the `conda` folder provides the RAPIDS meta-package, which
when installed will provide the latest RAPIDS libraries for the given version.

Test scripts in the `test` folder verify proper interaction across multiple
RAPIDS APIs.  Tests are separated into individual subfolders based on the usage
of a specific RAPIDS library with the other RAPIDS libs.

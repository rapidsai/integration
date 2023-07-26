# <div align="left"><img src="https://rapids.ai/assets/images/rapids_logo.png" width="90px"/>&nbsp; Meta-packages

## Overview

These packages provide one-line installs for RAPIDS as well as environment
setups for RAPIDS users and the RAPIDS [containers](https://github.com/rapidsai/build).

## Meta-packages

### Package Availability

These meta-packages are available in two channels:

Channel Name | Purpose
--- | ---
`rapidsai` | Release versions of the packages; tied to a stable release of RAPIDS
`rapidsai-nightly` | Nightly versions of the packages; allows for install of WIP nightly versions of RAPIDS

### Install Packages

The install meta-packages are for RAPIDS installation and version pinning of core
libraries to a RAPIDS release:

Package Name | Purpose
--- | ---
`rapids` | Provide a one package install for all RAPIDS libraries, version matched to a RAPIDS release
`rapids-xgboost` | Defines the version of `xgboost` used for a RAPIDS release

## Managing Versions

Packages without version restrictions do not need to use the following process
and can be simply added as a `conda` package name to the recipe. For all other
packages, follow this process to add/update versions used across all
meta-packages:

1. Examine the `meta.yaml` recipe to be modified
2. Check if there is a pre-existing version definition like
```
cupy {{ cupy_version }}
```
3. If so, skip to the section [Updating Versions](#updating-versions)
4. If not, continue with the section [Adding Versions](#adding-versions)

### Adding Versions

For new packages or those that do not have defined versions they need to be
added.

#### Modifying Recipes

To add a package with versioning to the recipe we need the `PACKAGE_NAME` and
the `VERSIONING_NAME` added to the file.

- `PACKAGE_NAME` - is the conda package name
- `VERSIONING_NAME` - is the conda package name with `-` replaced with `_` and a suffix of `_version` added
  - For example
    - `cupy` would become `cupy_version`
    - `scikit-learn` would become `scikit_learn_version`

Once the `PACKAGE_NAME` and `VERSIONING_NAME` are ready, we can add them to
the `meta.yml` as follows:

```
PACKAGE_NAME {{ VERSIONING_NAME }}
```

- **NOTE:** The `VERSIONING_NAME` must be surrounded by the `{{ }}` for the substitution to work.

Using our examples of `cupy` and `scikit-learn` we would have these entries in
the `meta.yaml`:

```
cupy {{ cupy_version }}
```
```
scikit-learn {{ scikit_learn_version }}
```

#### Modifying Versions File

In `conda/recipes` is `versions.yaml` - These are versions used by CI for testing in PRs and conda builds.

In this file we specify the version for the newly created `VERSIONING_NAME`.

For each `VERSIONING_NAME` we need a `VERSION_SPEC`. This can be any of the
standard `conda` version specifiers:
```
>=1.8.0
>=0.48,<0.49
>=7.0,<8.0.0a0
=2.5
```

##### TIP - Correct version specs

**NOTE:** `=2.5.*` is not a valid version spec. Please use `=2.5` instead
which will be interpreted as `=2.5.*`. Otherwise `conda build` throws a
warning message with the definition of `.*`. For example:

```
WARNING conda.models.version:get_matcher(531): Using .* with relational operator
is superfluous and deprecated and will be removed in a future version of conda.
Your spec was 0.23.*, but conda is ignoring the .* and treating it as 0.23
```

Combined together each of the versions files would add the following for each
`VERSIONING_NAME`:
```
VERSIONING_NAME:
  - 'VERSION_SPEC'
```

Using our examples of `cupy` and `scikit-learn` we would have these entries in
the `meta.yaml`:

```
cupy_version:
  - '>=7.0,<8.0.0a0'
```
```
scikit_learn_version:
  - '=0.21.3'
```

### Updating Versions

Edit the `versions.yaml` file in `conda/recipes` and update the `VERSION_SPEC`
as desired. If there is no defined version spec, see [Modifying Versions Files](#modifying-versions-files)
for information on how to add one.

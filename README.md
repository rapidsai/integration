# <div align="left"><img src="https://rapids.ai/assets/images/rapids_logo.png" width="90px"/>&nbsp; Integration

RAPIDS - combined conda package for all of RAPIDS libraries

## RAPIDS Metapackages

The conda recipe in the `conda` folder provides the RAPIDS metapackages, which when installed will provide the latest RAPIDS libraries for the given version.

See the [README](conda/recipes/README.md) for more information about the metapackages and how to update versions.

## dask Metapackage

This repository provides metapackages for pip and conda that centralize the dask version dependency across RAPIDS.
Dask's API instability means that each RAPIDS release must pin to a very specific dask release to avoid incompatibilities.
These metapackages provide a centralized, versioned storehouse for that pinning.
The `rapids_dask_dependency` encodes both `dask` and `distributed` requirements.

### Metapackage Versioning

The package is versioned by adding an extra release segment to the standard RAPIDS CalVer.
For example, the initial release of the metapackage for 23.10.00 will be 23.10.00.00
This version of the metapackage will always pull the latest nightlies for the dask and distributed packages.
RAPIDS repos will only pin up to the RAPIDS patch version, i.e. `==23.10.00.*`.

When RAPIDS hits code freeze and we pin dask versions, the package versions in this repository should be pinned.
At this time, a new metapackage will be released, 23.10.00.1.
This new metapackage version will be automatically picked up by other RAPIDS libraries since they will be using a `==23.10.00.*` pin.

### Requiring Dask nightlies

Prior to final pinning for a release, Dask versions should be specified using PEP 440-compatible versions like `>=2023.7.1a0` so that nightlies may be picked up.
For conda, nightlies are published to the [dask channel](https://anaconda.org/dask/).
The metapackage assumes that the `dask/label/dev` channel is included in a user's condarc so that the nightly will be found.
For pip, no nightlies are published so the packages must be installed directly from source.
To do so, the metapackage will encode dependencies as:
```
- dask @ git+https://github.com/dask/dask.git@main
- distributed @ git+https://github.com/dask/distributed.git@main
```

### RAPIDS patch releases

If RAPIDS itself requires a patch release, a new metapackage version will be released that bumps the patch version e.g. 23.10.01.0.
RAPIDS libraries should at this time update their metapackage pinnings to be `==23.10.01.*` so that metapackages corresponding to the patch release are detected.
Note that patch releases are why we must specify `==` rather than `>=` constraints.
We do not want a new metapackage release for a RAPIDS patch release to affect lower patch releases, because a patch release of RAPIDS could involve Dask changes, necessitating a bump in the Dask pinning that we do not want to propagate backwards to the previous patch release.

# shipdist

Recipes to build `FairShip` and it's dependencies using `aliBuild`

## General information

For general documentation, please refer to the `alisw/alibuild` documentation pages.

### Defaults

Defaults in use:

- `fairship`: Default for use with `FairShip/master`
- `fairship-2018`: Default for use with `FairShip/muflux` and legacy branches

### Troubleshooting tips

#### `aliDoctor`

#### `aliDeps`

#### `aliBuild init` and local development packages

## Platform specific information

Information for different platforms available below.

If you are working on a platform that is not listed below, `containers/toolbox` or `docker` can be used to conveniently set up a working environment with e.g. Fedora.

### With CVMFS

On platforms which can use CVMFS, most dependencies can be used form CVMFS and don't need to be built locally. Information to follow.

### Ubuntu 18.04.X

Known to work. Information to follow.

### CERN CentOS 7

Known to work. Tested on `lxplus7` and base of official container image. Information to follow.

### Fedora 30

Confirmed to work. Tested using `container/toolbox`.

#### Dependencies

#### Local Packages

The following packages are used from the system:

- `zlib`
- `autotools`
- `GCC-Toolchain`
- `Python`
- `libxml2`
- `Python-modules`
- `FreeType`

Everything else is used from `aliBuild`/`shipdist`.

### Fedora 31

Tested using `container/toolbox`.

#### Dependencies

```bash
sudo dnf install -y mysql-devel curl-devel bzip2-devel auto{conf,make} texinfo gettext{,-devel} libtool freetype-devel libpng-devel sqlite{,-devel}  ncurses-devel mesa-libGLU-devel libX11-devel libXpm-devel libXext-devel libXft-devel libxml2-devel motif{,-devel} kernel-devel pciutils-devel kmod-devel bison flex perl-ExtUtils-Embed environment-modules gcc-{gfortran,c++} swig make krb5-{workstation,devel}
```

#### Local Packages

The following packages are used from the system:

- `libpng`
- `libxml2`
- `sqlite`
- `GCC-Toolchain`
- `autotools`
- `FreeType`
- `zlib`

### macOS

Known to **NOT** work, but there is interest to make it work.

Please write to the `ship-software` egroup, if you are interested in helping.

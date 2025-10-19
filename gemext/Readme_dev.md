# requirements

For computers with admin/root access, the prerequisite libraries are revealed by:

```sh
cmake -P scripts/requirements.cmake
```

## Python

If a new enough Python isn't available on your system, you can build Python via project
[cmake-python-build](https://github.com/gemini3d/cmake-python-build).

## Development: local source directory(ies)

The options for this project are typically contained in [options.cmake](./options.cmake).

For development, one can specify a local source directory(ies) to build from like:

```sh
cmake -Dmypkg_source=/path/to/my_glow_code ...
```

That assumes the source directory that you're making changes is at the path specified.
Git/downloading is not used for that library.
The libraries this work for include:

```
lapack scalapack mumps
```

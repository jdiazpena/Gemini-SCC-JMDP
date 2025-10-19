# CMake update

If you get an error message stating CMake is too old, install a recent CMake version by:

```sh
cmake -P scripts/install_cmake.cmake
```

If you don't yet have CMake at all, try:

```sh
bash scripts/install_cmake.sh
```

If that script doesn't work, try to build CMake from source:

```sh
cmake -P scripts/build_cmake.cmake
```

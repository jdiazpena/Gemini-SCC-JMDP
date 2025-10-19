# Offline: Build Gemini3D and external libraries

For computers where Internet is not available, one must have a "gemini_package.tar" copied
to the computer that was previously created by the "package.cmake" script in this repo, as discussed at the bottom of this Readme.

```sh
cmake -E tar x /path/to/gemini_package.tar build-offline.cmake
# extracts build-offline.cmake to current directory, which is arbitrary

cmake -Dtarfile=/path/to/gemini_package.tar -P build-offline.cmake
# build Gemini3D and external libraries without Internet, installing to ~/libgem by default
```

## Offline packaging

Some computing environments can't easily use the internet.
To support these users, create an archive of all Gemini3D library software stack like:

```sh
cmake -P scripts/package.cmake
```

Which creates a "gemini_package.tar" containing all the source code used by this project and external libraries.

The end-user on the offline computer would use this gemini_package.tar as follows.
This command can be executed from any directory, the build will take place under the directory where the gemini_package.tar file is located.
In this example below for /path/to/gemini_package.tar the build directory would be /path/to/external/ and /path/to/gemini3d/

```sh
tar
cmake -Dprefix=$HOME/libgem -Dtarfile=/path/to/gemini_package.tar -P build-offline.cmake
```

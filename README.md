# zig2wapm

Since the CI sometimes fails to build the repository, you need to build a
Linux machine to pre-build the `zig.wapm` file.

Build with:

```
# if $VERSION is not specified defaults to "master" / latest version
VERSION=x.y.z ./build.sh
git add .
git commit # commit the built zig.wasm file
git push
```

In order to then build + publish the final version, 
you need to trigger the GitHub action with the same 
version that was already pushed (i.e. `master` or `x.y.z`).

This will publish the action to `$secrets.WAPM_REGISTRY`.

Note: currently only the `master` version builds on WASI, 
other versions are not supported by Zig.
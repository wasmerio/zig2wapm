v=${VERSION:="master"}
echo "building $v"
echo "[1/10] removing old build directories..."
rm -f ./index.json
rm -rf ./zig-bin
rm -rf ./zig-src
echo "[2/10] installing cargo sd..."
cargo install sd
echo "[3/10] fetching latest ziglang.org/download/index.json..."
curl https://ziglang.org/download/index.json --silent -o ./index.json

if [[ $(uname -m) == 'arm64' ]]; then
    binarytarballquery=".'$v'.'aarch64-macos'.tarball"
else
    binarytarballquery=".'$v'.'x86_64-linux'.tarball"
fi
binarytarballquery=$(echo $binarytarballquery | sed "s/'/\"/g")
binarytarball=$(jq -r $binarytarballquery ./index.json)

srctarballquery=".'$v'.src.tarball"
srctarballquery=$(echo $srctarballquery | sed "s/'/\"/g")
srctarball=$(jq -r $srctarballquery ./index.json)
version=$v
if [ "$version" = "master" ]; then
    version=$(jq -r .master.version ./index.json)
fi
echo "[4/10] changing wapm.toml username and version"
sed -i "s/version = \".*\"/version = \"${version}\"/g" ./wapm.toml && \
sdreplace="[package]\nname = \\\"$WAPM_DEV_USERNAME/zig\\\""
sd "\[package\]\nname = \".*\"" "$sdreplace" ./wapm.toml
cat ./wapm.toml
echo "[5/10] downloading $binarytarball (zig version $version)"
curl --silent -o ./zig-bin.tar.gz $(echo $binarytarball)
echo "[6/10] downloading $srctarball (zig src version $version)"
curl --silent -o ./zig-src.tar.gz $(echo $srctarball)
echo "[7/10] unpacking zig-bin.tar.gz"
mkdir -p ./zig-bin
tar -xf ./zig-bin.tar.gz --strip-components=1 -C ./zig-bin
echo "[8/10] unpacking zig-src.tar.gz"
mkdir -p ./zig-src
tar -xf ./zig-src.tar.gz --strip-components=1 -C ./zig-src
cd zig-src
echo "[9/10] building zig.wasm"
../zig-bin/zig build -Dtarget=wasm32-wasi -Drelease
cd ..
mkdir -p zig2wapm
cp ./wapm.toml ./zig2wapm
cp ./README.md ./zig2wapm
cat ./DESCRIPTION.md > ./zig2wapm/README.md
cd zig2wapm
mkdir empty-cache
touch empty-cache/.dummyfile
mkdir zig
cp -R ../zig-src/zig-out/bin ./zig
cp -R ../zig-src/zig-out/lib ./zig
cp ./zig/bin/zig.wasm .
# in some cases the build fails on the CI, but not locally for unknown reasons
# therefore this will use the root "zig.wasm" file in case the build has failed
cp ./zig/bin/zig.wasm ../../
mkdir -p ./zig/bin
cp -n ../../zig.wasm ./zig/bin
cp -n ../../zig.wasm .
echo "[10/10] packaging zig.wasm in:"
pwd

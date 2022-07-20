echo "[1/10] removing old build directories..."
rm -f ./index.json
rm -rf ./zig-linux
echo "[2/10] installing cargo sd..."
cargo install sd
echo "[3/10] fetching latest ziglang.org/download/index.json..."
curl https://ziglang.org/download/index.json --silent --out ./index.json
tarball=$(jq -r '.master."x86_64-linux".tarball' ./index.json)
version=$(jq -r .master.version ./index.json)
echo "[4/10] downloading $tarball (zig version $version)"
curl --out ./zig-linux.tar.gz $(echo $tarball)
echo "[5/10] changing wapm.toml username and version"
sed -i "s/version = \".*\"/version = \"${version}\"/g" ./wapm.toml && \
sd "\[package\]\nname = \"wapm2pirita\"" "[package]\nname = \"${WAPM_DEV_USERNAME}/wapm2pirita\"" ./wapm.toml
cat ./wapm.toml
echo "[6/10] unpacking zig-linux.tar.gz"
mkdir -p ./zig-linux
tar -xf ./zig-linux.tar.gz --strip-components=1 -C ./zig-linux
cd zig-linux
mkdir -p zigbuild
cd zigbuild
echo "[7/10] cloning https://github.com/ziglang/zig"
git clone --depth 1 https://github.com/ziglang/zig
cd zig
echo "[8/10] building zig.wasm"
../../zig build -Dtarget=wasm32-wasi
mkdir -p zig2wapm
cp ../../../wapm.toml ./zig2wapm
cp ./zig-out/bin/zig.wasm ./zig2wapm
cd zig2wapm
echo "[9/10] packaging zig.wasm in:"
pwd
echo "directory:"
ls
wapm config set registry.url $WAPM_REGISTRY
echo "[10/10] uploading to wapm.io using WAPM_REGISTRY_TOKEN:"
echo "$WAPM_REGISTRY_TOKEN"
wapm publish # uses WAPM_REGISTRY_TOKEN env var

echo "[1/10] removing old build directories..."
rm -f ./index.json
rm -rf ./zig-linux
rm -rf ./zig-src
echo "[2/10] installing cargo sd..."
cargo install sd
echo "[3/10] fetching latest ziglang.org/download/index.json..."
curl https://ziglang.org/download/index.json --silent --out ./index.json
binarytarball=$(jq -r '.master."x86_64-linux".tarball' ./index.json)
srctarball=$(jq -r '.master.src.tarball' ./index.json)
version=$(jq -r .master.version ./index.json)
echo "[4/10] changing wapm.toml username and version"
sed -i "s/version = \".*\"/version = \"${version}\"/g" ./wapm.toml && \
sd "\[package\]\nname = \"wapm2pirita\"" "[package]\nname = \"${WAPM_DEV_USERNAME}/wapm2pirita\"" ./wapm.toml
cat ./wapm.toml
echo "[5/10] downloading $binarytarball (zig version $version)"
curl --out ./zig-linux.tar.gz $(echo $binarytarball)
echo "[6/10] downloading $srctarball (zig src version $version)"
curl --out ./zig-src.tar.gz $(echo $srctarball)
echo "[7/10] unpacking zig-linux.tar.gz"
mkdir -p ./zig-linux
tar -xf ./zig-linux.tar.gz --strip-components=1 -C ./zig-linux
echo "[8/10] unpacking zig-src.tar.gz"
mkdir -p ./zig-src
tar -xf ./zig-src.tar.gz --strip-components=1 -C ./zig-src
cd zig-src
echo "[8/10] building zig.wasm"
../zig-linux/zig build -Dtarget=wasm32-wasi
mkdir -p zig2wapm
cp ../wapm.toml ./zig2wapm
cp ../README.md ./zig2wapm
cp ./zig-out/bin/zig.wasm ./zig2wapm
cat ../DESCRIPTION.md > ./zig2wapm/README.md
cd zig2wapm
mkdir empty-cache
touch empty-cache/.dummyfile
mkdir zig
cp -R ../zig-out/bin ./zig
cp -R ../zig-out/lib ./zig
echo "[9/10] packaging zig.wasm in:"
pwd
echo "directory:"
du -a
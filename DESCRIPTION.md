An experimental compilation of Zig's "stage2" compiler to WASI.

This compiler is not yet feature-complete, and some valid Zig programs do not compile correctly.

This one does, though:

```zig
const std = @import("std");
pub fn main() void {
    const stdout = std.io.getStdOut();
    stdout.writeAll("Hello world!") catch unreachable;
}
```
const std = @import("std");
const output = @import("output.zig");
const particleSystem = @import("particleSystem.zig");

fn parseAscii(path: []const u8, buf: []u8) !void {
    _ = try std.fs.cwd().readFile(path, buf);
}

pub fn main() !void {
    var buffer: [particleSystem.ROWS * particleSystem.COLS]u8 = undefined;
    try parseAscii("cup.txt", &buffer);

    var ps = particleSystem.ParticleSystem.init(42);

    ps.withAsciiSeed(&buffer);
    //ps.updateAll();
    //try ps.renderAll();

    while (true) {
        ps.updateAll();
        try ps.renderAll();
        std.time.sleep(1_000_000_000);
    }
}

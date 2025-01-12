const std = @import("std");
const particle = @import("particle.zig");
const output = @import("output.zig");

pub const ROWS: usize = 50;
pub const COLS: usize = 100;

pub const LAST_DRAWABLE_ROW: usize = 13;

pub const ParticleSystem = struct {
    particles: [ROWS][COLS]particle.Particle,

    pub fn init(seed: usize) ParticleSystem {
        var tmp: [ROWS][COLS]particle.Particle = undefined;
        var rand = std.rand.DefaultPrng.init(seed);
        const rng = rand.random();
        for (0..ROWS) |i| {
            for (0..COLS) |j| {
                const _seed = rng.uintAtMost(usize, 255);
                tmp[i][j] = particle.Particle.init(i, j, _seed, true); // make immutable
            }
        }

        return ParticleSystem{
            .particles = tmp,
        };
    }

    pub fn withAsciiSeed(self: *ParticleSystem, buf: []u8) void {
        var row: usize = 0;
        var col: usize = 0;

        var iter = std.mem.split(u8, buf, "\n");
        while (iter.next()) |s| {
            col = 0;
            for (s) |ch| {
                if (ch != ' ') {
                    self.particles[row][col].forceCharacter(ch);
                } else {
                    if (row <= LAST_DRAWABLE_ROW) {
                        self.particles[row][col].unfix();
                    }
                }
                col += 1;
            }
            row += 1;
        }
    }

    pub fn updateAll(self: *ParticleSystem) void {
        for (0..ROWS) |i| {
            for (0..COLS) |j| {
                self.particles[i][j].update();
            }
        }
    }

    pub fn renderAll(self: *ParticleSystem) !void {
        try output.stdout.print("\x1b[H", .{});
        for (0..ROWS) |i| {
            for (0..COLS) |j| {
                try self.particles[i][j].render();
            }
            try output.stdout.print("\n", .{});
        }
        try output.flush();
    }
};

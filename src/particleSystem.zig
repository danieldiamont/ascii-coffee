const std = @import("std");
const particle = @import("particle.zig");
const output = @import("output.zig");

pub const ROWS: usize = 50;
pub const COLS: usize = 100;

pub const LAST_DRAWABLE_ROW: usize = 13;
pub const FIRST_DRAWABLE_COL: usize = 7;
pub const LAST_DRAWABLE_COL: usize = 86;

pub const ParticleSystem = struct {
    particles: [ROWS * COLS]particle.Particle,
    canvas: [ROWS][COLS]u8,

    pub fn init(seed: usize) ParticleSystem {
        var tmp: [ROWS * COLS]particle.Particle = undefined;
        var canvas: [ROWS][COLS]u8 = undefined;
        var rand = std.rand.DefaultPrng.init(seed);
        const rng = rand.random();
        for (0..ROWS) |i| {
            for (0..COLS) |j| {
                const _seed = rng.uintAtMost(usize, 255);
                tmp[i * COLS + j] = particle.Particle.init(i, j, _seed, true);
                canvas[i][j] = ' ';
            }
        }

        return ParticleSystem{
            .particles = tmp,
            .canvas = canvas,
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
                    self.particles[(row * COLS) + col].forceCharacter(ch);
                } else {
                    if (filter(row, col)) {
                        self.particles[(row * COLS) + col].unfix();
                    }
                }
                col += 1;
            }
            row += 1;
        }
    }

    pub fn updateAll(self: *ParticleSystem) void {
        for (&self.particles) |*p| {
            p.update();
        }
    }

    pub fn renderAll(self: *ParticleSystem) !void {
        try output.stdout.print("\x1b[H", .{});

        for (&self.particles) |*p| {
            const row = p.getRow();
            const col = p.getCol();
            const ch = p.render();
            self.canvas[row][col] = ch;
            //std.log.debug("({d}, {d}) = {c}", .{ row, col, ch });
        }

        for (0..ROWS) |r| {
            for (0..COLS) |c| {
                try output.stdout.print("{c}", .{self.canvas[r][c]});
            }
            try output.stdout.print("\n", .{});
        }

        try output.flush();
    }

    fn filter(row: usize, col: usize) bool {
        if (row <= LAST_DRAWABLE_ROW and col >= FIRST_DRAWABLE_COL and col < LAST_DRAWABLE_COL) {
            return true;
        }
        return false;
    }
};

const std = @import("std");
const particle = @import("particle.zig");
const output = @import("output.zig");

pub const ROWS: usize = 50;
pub const COLS: usize = 100;

pub const FIRST_DRAWABLE_ROW: usize = 1;
pub const LAST_DRAWABLE_ROW: usize = 14;
pub const FIRST_DRAWABLE_COL: usize = 7;
pub const LAST_DRAWABLE_COL: usize = 86;

pub const ParticleSystem = struct {
    particles: std.ArrayList(particle.Particle),
    canvas: [ROWS][COLS]u8,
    seed: usize,
    speed: f64,
    tick: usize,
    interval: usize,
    rand: std.rand.DefaultPrng,

    pub fn init(seed: usize, speed: f64, alloc: std.mem.Allocator) ParticleSystem {
        const interval: usize = @intFromFloat(@abs(1.0 / speed));

        return ParticleSystem{
            .particles = std.ArrayList(particle.Particle).init(alloc),
            .canvas = undefined,
            .seed = seed,
            .speed = speed,
            .tick = 0,
            .interval = interval,
            .rand = std.rand.DefaultPrng.init(seed),
        };
    }

    pub fn withAsciiSeed(self: *ParticleSystem, buf: []u8) !void {
        var row: usize = 0;
        var col: usize = 0;

        var iter = std.mem.split(u8, buf, "\n");
        while (iter.next()) |s| {
            col = 0;
            for (s) |ch| {
                if (ch != ' ') {
                    var p = particle.Particle.init(row, col, self.speed, 0.0, 42, 0.5);
                    p.forceCharacter(ch);
                    try self.particles.append(p);
                }
                col += 1;
            }
            row += 1;
        }
    }

    pub fn updateAll(self: *ParticleSystem) !void {
        // check for dead
        var alive = std.ArrayList(particle.Particle).init(std.heap.page_allocator);
        defer alive.deinit();
        for (self.particles.items) |p| {
            if (p.fixed == true) {
                try alive.append(p);
                continue;
            }
            if (!checkOutOfBounds(p)) {
                try alive.append(p);
            }
        }

        self.particles.clearAndFree();
        for (alive.items) |p| {
            try self.particles.append(p);
        }

        // spawn new particles
        const rng = self.rand.random();

        if (self.tick == 0) {
            for (FIRST_DRAWABLE_COL..LAST_DRAWABLE_COL) |col| {
                const row = LAST_DRAWABLE_ROW;
                const seed = rng.uintAtMost(usize, 1024);
                var p = particle.Particle.init(row, col, self.speed, 0.0, seed, 0.5);
                p.unfix();
                try self.particles.append(p);
            }
        }

        for (self.particles.items) |*p| {
            p.update();
        }

        self.tick = (self.tick + 1) % self.interval;
    }

    pub fn renderAll(self: *ParticleSystem) !void {
        try output.stdout.print("\x1b[H", .{});

        // clear canvas
        for (0..ROWS) |r| {
            for (0..COLS) |c| {
                self.canvas[r][c] = ' ';
            }
        }

        // render particles
        for (self.particles.items) |*p| {
            const row = p.getRow();
            const col = p.getCol();
            const ch = p.render();
            self.canvas[row][col] = ch;
            //std.log.debug("({d}, {d}) = {c}", .{ row, col, ch });
        }

        // display canvas
        for (0..ROWS) |r| {
            for (0..COLS) |c| {
                try output.stdout.print("{c}", .{self.canvas[r][c]});
            }
            try output.stdout.print("\n", .{});
        }

        try output.flush();
    }

    fn checkOutOfBounds(p: particle.Particle) bool {
        if (p.row < FIRST_DRAWABLE_ROW or p.row > LAST_DRAWABLE_ROW) {
            return true;
        }
        if (p.col < FIRST_DRAWABLE_COL or p.col > LAST_DRAWABLE_COL) {
            return true;
        }
        return false;
    }
};

const std = @import("std");
const output = @import("output.zig");

pub const Particle = struct {
    row: f64,
    col: f64,
    drow: f64,
    dcol: f64,
    row_init: f64,
    col_init: f64,
    value: f64,
    ch: u8,
    rng: std.Random,
    fixed: bool,

    pub fn init(row: usize, col: usize, seed: usize, fixed: bool) Particle {
        const _row: f64 = @floatFromInt(row);
        const _col: f64 = @floatFromInt(col);

        var rand = std.rand.DefaultPrng.init(seed);
        const rng = rand.random();

        return Particle{ .row = _row, .col = _col, .drow = 0, .dcol = 0, .row_init = _row, .col_init = _col, .value = 0, .rng = rng, .fixed = fixed, .ch = ' ' };
    }

    pub fn render(self: *Particle) !void {
        if (self.fixed == false) {
            self.ch = map(self.value);
        }
        try output.stdout.print("{c}", .{self.ch});
    }

    pub fn update(self: *Particle) void {
        if (self.fixed == false) {
            // do update position logic
            const f = self.rng.floatNorm(f64);
            self.value = f;
        } else {}
    }

    pub fn unfix(self: *Particle) void {
        self.fixed = false;
    }

    pub fn forceCharacter(self: *Particle, ch: u8) void {
        self.ch = ch;
    }

    pub fn map(f: f64) u8 {
        if (f < -3) {
            return '<';
        } else if (f >= -3 and f < -2) {
            return '{';
        } else if (f >= -2 and f < -1) {
            return '(';
        } else if (f >= -1 and f < 1) {
            return '|';
        } else if (f >= 1 and f < 2) {
            return ')';
        } else {
            return '>';
        }
    }

    // pub fn filter(self: Particle) bool {

    // }
};

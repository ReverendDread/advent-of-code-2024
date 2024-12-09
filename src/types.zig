const std = @import("std");

pub const AdventOfCodeDay = struct {
    day: []const u8,
    main: fn(std.mem.Allocator, [][:0]u8) anyerror!void,
};
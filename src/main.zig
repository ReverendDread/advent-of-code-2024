const std = @import("std");
const types = @import("types.zig");
const day01 = @import("day01.zig").day01();
const day02 = @import("day02.zig").day02();

const days = [_]types.AdventOfCodeDay{day01, day02};

// allows us to run days from the command line with `zig run` and pass in the day number
pub fn main() !void {
    // use general purpose allocator for all allocations in each day 
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer _ = arena.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const day_number = args[1];
    
    inline for (days) |day| {
        if (std.mem.eql(u8, day_number, day.day)) {
            try day.main(allocator, args[2..]);
        }
    }
}

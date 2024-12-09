const std = @import("std");
const types = @import("types.zig");

const data = @embedFile("./inputs/day01.txt");

pub fn day01() types.AdventOfCodeDay {
    return types.AdventOfCodeDay{
        .day = "day01",
        .main = main,
    };
}

const RowSet = struct {
    left_numbers: std.ArrayList(u32),
    right_numbers: std.ArrayList(u32),
};

fn main(allocator: std.mem.Allocator, args: []const [:0]u8) !void {
    std.debug.print("Args: {any}\n", .{args});

    const part1Result = try part1(allocator);
    std.debug.print("Part 1: {any}\n", .{part1Result});

    const part2Result = try part2(allocator);
    std.debug.print("Part 2: {any}\n", .{part2Result});
}

// calculate the sum of the differences between the two columns
fn part1(allocator: std.mem.Allocator) !u32 {
    const rows = try parse_rows(allocator);

    const left_numbers = rows.left_numbers;
    const right_numbers = rows.right_numbers;

    // calculate the sum of the differences between the two columns
    var sum: u32 = 0;
    for (left_numbers.items, right_numbers.items) |left, right| {
        sum += @max(left, right) - @min(left, right);
    }
    return sum;
}

// calculate the similarity between the two columns
fn part2(allocator: std.mem.Allocator) !u32 {
    const rows = try parse_rows(allocator);

    const left_numbers = rows.left_numbers;
    const right_numbers = rows.right_numbers;

    var sum: u32 = 0;
    for (left_numbers.items) |left| {
        sum += left * @as(u32, @intCast(std.mem.count(u32, right_numbers.items, &.{left})));
    }
    return sum;
}

// parse the rows of the input file into two columns 
fn parse_rows(allocator: std.mem.Allocator) !RowSet {
    var left_numbers = std.ArrayList(u32).init(allocator);
    var right_numbers = std.ArrayList(u32).init(allocator);

    var line_iter = std.mem.tokenize(u8, data, "\n");

    // parse the tokens into the left and right columns
    while (line_iter.next()) |line| {
        var num_iter = std.mem.tokenize(u8, line, " ");

        const left_num = try parse_int(num_iter.next().?);
        const right_num = try parse_int(num_iter.next().?);

        try left_numbers.append(left_num);
        try right_numbers.append(right_num);
    }

    // sort the columns by ascending order
    std.mem.sort(u32, left_numbers.items, {}, std.sort.asc(u32));
    std.mem.sort(u32, right_numbers.items, {}, std.sort.asc(u32));

    return RowSet { 
        .left_numbers  = left_numbers, 
        .right_numbers  = right_numbers 
    };
} 

// remove any whitespace and parse the string into an integer
fn parse_int(str: []const u8) !u32 {
    const _str = std.mem.trim(u8, str, "\r\n");
    return  try std.fmt.parseInt(u32, _str, 10);
}
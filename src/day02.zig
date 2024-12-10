const std = @import("std");
const types = @import("types.zig");

const data = @embedFile("./inputs/day02.txt");

const SAFE_REPORT_THRESHOLD = 3;

const Report = struct { 
    id: u32,
    levels: []i32,

    // check if the report is safe against the threshold
    fn is_safe(self: @This()) bool {
        return evaluate_safety(self.levels);
    }

};

pub fn day02() types.AdventOfCodeDay {
    return types.AdventOfCodeDay{
        .day = "day02",
        .main = main,
    };
}

fn main(allocator: std.mem.Allocator, args: []const [:0]u8) !void {
    std.debug.print("Args: {any}\n", .{args});

    const part1Result = try part1(allocator);
    std.debug.print("Part 1: {any}\n", .{part1Result});

    const part2Result = try part2(allocator);
    std.debug.print("Part 2: {any}\n", .{part2Result});
}

// calculate the sum of the differences between the two columns
fn part1(allocator: std.mem.Allocator) !i32 {
    const reports = try parse_reports(allocator);
    var count: i32 = 0;
    for (reports.items) |report| {
        if (report.is_safe()) {
            count += 1;
        }
    }
    return count;
}

// calculate the similarity between the two columns
fn part2(allocator: std.mem.Allocator) !i32 {
    const reports = try parse_reports(allocator);
    var count: i32 = 0;

    for (reports.items) |report| {
        if (try evaluate_tolerance(allocator, report.levels)) {
            count += 1;
        }
    }
    return count;
}

// parse lines of the file into reports
fn parse_reports(allocator: std.mem.Allocator) !std.ArrayList(Report) {
    var reports = std.ArrayList(Report).init(allocator);
    var line_iter = std.mem.tokenize(u8, data, "\n");
    var idx: u32 = 0;
    while (line_iter.next()) |line| {
        var lvl_iter = std.mem.tokenize(u8, line, " ");
        var levels = std.ArrayList(i32).init(allocator);
        while (lvl_iter.next()) |level| {
            const lvl = try parse_int(level);
            try levels.append(lvl);
        }

        const report = Report{
            .id = idx,
            .levels = levels.items,
        };

        try reports.append(report);
        idx += 1;
    }
    return reports;
}

fn evaluate_tolerance(allocator: std.mem.Allocator, items: []i32) !bool {
    if (evaluate_safety(items)) {
        return true;
    }

    const len = items.len;
    const buff = try allocator.alloc(i32, len);

    defer allocator.free(buff);

    // re-evaluate the items with one item removed at a time
    for (items, 0..) |_, index| {
        var modified_items = buff[0..len - 1];
        @memcpy(modified_items[0..index], items[0..index]);
        @memcpy(modified_items[index..], items[index + 1..]);

        // check if the modified items are safe
        if (evaluate_safety(modified_items)) {
            return true;
        }
    }
    return false;
}

// evaluate the items against the safety threshold in a windowed manner
fn evaluate_safety(items: []i32) bool {
    var is_decending = true;
    var is_ascending = true;
    for (items[0..items.len - 1], items[1..]) |prev, next| {
        const diff = @abs(prev - next);
        // check if the difference is within the threshold
        if (diff < 1 or diff > SAFE_REPORT_THRESHOLD) {
            return false;
        }
        // going up or staying the same
        if (prev < next) {
            is_decending = false;
        }
        // going down or staying the same
        if (prev > next) {
            is_ascending = false;
        }
    }

    return !((is_ascending and is_decending) or (!is_ascending and !is_decending));
}

// safe integer parsing
fn parse_int(str: []const u8) !i32 {
    const _str = std.mem.trim(u8, str, "\r\n");
    return try std.fmt.parseInt(i32, _str, 10);
}
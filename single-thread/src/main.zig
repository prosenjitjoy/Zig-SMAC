const std = @import("std");
const stdout = std.io.getStdOut().writer();
const allocator = std.heap.page_allocator;

pub fn main() !void {
    var biglist = std.ArrayList(u8).init(allocator);
    defer biglist.deinit();

    for (1..1000001) |index| {
        if (index % 10 == 7 or index % 7 == 0) {
            try biglist.writer().print("SMAC\n", .{});
        } else {
            try biglist.writer().print("{d}\n", .{index});
        }
    }

    try printList(&biglist);
}

fn printList(list: *std.ArrayList(u8)) !void {
    var iter = std.mem.split(u8, list.items, "\n");

    while (iter.next()) |item| {
        try stdout.print("{s}\n", .{item});
    }
}

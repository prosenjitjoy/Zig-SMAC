const std = @import("std");
const stdout = std.io.getStdOut().writer();
const allocator = std.heap.page_allocator;

pub fn main() !void {
    const x = 4;
    var thread: [x]std.Thread = undefined;
    var list: [x]std.ArrayList(u8) = undefined;

    for (0..x) |i| {
        list[i] = std.ArrayList(u8).init(allocator);
        defer list[i].deinit();
        thread[i] = try std.Thread.spawn(.{}, countIt, .{ i, &list[i] });
    }

    for (0..x) |i| {
        thread[i].join();
        try printList(&list[i]);
        list[i].clearAndFree();
    }
}

fn countIt(i: usize, list: *std.ArrayList(u8)) !void {
    var addr: usize = 0;
    if (i == 3) addr += 1;

    var index: usize = i * 250_000;
    while (index < (i * 250_000 + 250_000 + addr)) : (index += 1) {
        if (index == 0) continue;
        if (index % 10 == 7 or index % 7 == 0) {
            try list.writer().print("SMAC\n", .{});
        } else {
            try list.writer().print("{d}\n", .{index});
        }
    }
}

fn printList(list: *std.ArrayList(u8)) !void {
    var iter = std.mem.split(u8, list.items, "\n");

    while (iter.next()) |item| {
        try stdout.print("{s}\n", .{item});
    }
}

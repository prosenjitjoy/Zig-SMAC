const std = @import("std");
const stdout = std.io.getStdOut().writer();
const allocator = std.heap.page_allocator;
const net = std.net;

pub fn main() !void {
    var biglist = std.ArrayList(u8).init(allocator);
    defer biglist.deinit();

    for (1..1000001) |index| {
        if (index % 10 == 7 or index % 7 == 0) {
            try biglist.writer().print("SMAC\n|", .{});
        } else {
            try biglist.writer().print("{d}\n|", .{index});
        }
    }

    var server = net.StreamServer.init(.{});
    server.reuse_address = true;
    defer server.deinit();

    try server.listen(try net.Address.parseIp("0.0.0.0", 8080));
    try stdout.print("Listening on {}\n", .{server.listen_address});

    while (true) {
        var conn = try server.accept();
        _ = try std.Thread.spawn(.{}, printList, .{ &biglist, conn });
    }
}

fn printList(list: *std.ArrayList(u8), conn: net.StreamServer.Connection) !void {
    var iter = std.mem.split(u8, list.items, "|");

    while (iter.next()) |item| {
        _ = try conn.stream.write(item);
    }

    conn.stream.close();
}

const std = @import("std");

pub const Options = struct {};

pub fn run(alloc: std.mem.Allocator, opts: Options) !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    _ = opts;
    _ = alloc;
    while (true) {
        try std.fmt.format(stdout, "$ ", .{});
        var readBuffer: [512]u8 = undefined;
        const result = try stdin.read(readBuffer[0..]);
        std.log.info("{s}", .{readBuffer[0..result]});
        return;
    }
}

const std = @import("std");
const execute = @import("execute.zig");

pub const Options = struct {};

pub fn run(alloc: std.mem.Allocator, opts: Options) !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    _ = opts;
    while (true) {
        try std.fmt.format(stdout, "$ ", .{});
        var readBuffer: [512]u8 = undefined;
        const equation = readBuffer[0..try stdin.read(readBuffer[0..])];
        if (std.mem.eql(u8, "quit", std.mem.trim(u8, equation, std.ascii.whitespace[0..]))) return;

        const result = try execute.execute(equation, alloc);
        std.log.info("{s} => {}", .{ equation, result });
    }
}

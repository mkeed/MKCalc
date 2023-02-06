const std = @import("std");
const execute = @import("execute.zig");

pub const Options = struct {};

const inputs = [_][]const u8{
    "1 + 1 + 2",
    "1#kg * 1#m",
    "1 + min([1,2,3,4])",
};

pub fn run(alloc: std.mem.Allocator, opts: Options) !void {
    const stdout = std.io.getStdOut().writer();
    //const stdin = std.io.getStdIn().reader();

    _ = opts;
    var count: usize = 0;
    while (true) {
        defer count += 1;
        try std.fmt.format(stdout, "$ ", .{});
        //var readBuffer: [512]u8 = undefined;
        const equation = if (count < inputs.len) inputs[count] else return;
        //readBuffer[0..try stdin.read(readBuffer[0..])];
        if (std.mem.eql(u8, "quit", std.mem.trim(u8, equation, std.ascii.whitespace[0..]))) return;

        const result = try execute.execute(equation, alloc);
        std.log.info("{s} => {}", .{ equation, result });
    }
}

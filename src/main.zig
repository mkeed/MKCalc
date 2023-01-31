const std = @import("std");
const draw = @import("Draw.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const items = [_]draw.DrawItem{
        .{
            .equation = "10 + 1",
            .result = .{
                .dec = "11",
                .hex = "0xA",
                .binary = &.{ true, false, true, false },
            },
        },
        .{
            .equation = "12 + 01",
            .result = .{
                .dec = "13",
                .hex = "0xB",
                .binary = &.{ true, false, true, true },
            },
        },
    };

    try draw.DrawScreen(&items, .{ .rows = 20, .cols = 64 }, 0, stdout);

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

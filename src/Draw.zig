const std = @import("std");

pub const DrawItem = struct {
    equation: []const u8,
    result: Result,
};

pub const Result = struct {
    dec: []const u8,
    hex: []const u8,
    binary: []const bool,
};
pub const ScreenSize = struct {
    rows: usize,
    cols: usize,
};
pub fn DrawScreen(items: []const DrawItem, screenSize: ScreenSize, selection: usize, writer: anytype) !void {
    //
    const dashes = [1]u8{'-'} ** 256;
    const lineSeperator = if (screenSize.cols / 2 < dashes.len) dashes[0 .. screenSize.cols / 2] else dashes[0..];

    for (items) |item, idx| {
        const lineEnd = if (idx == selection) "█\n" else " \n";

        try std.fmt.format(writer, "{s}\n", .{lineSeperator});

        try std.fmt.format(writer, "{s}", .{item.equation});
        try writer.writeByteNTimes(' ', lineSeperator.len - item.equation.len);

        try std.fmt.format(writer, "{s}", .{lineEnd});
        try writer.writeByteNTimes(' ', lineSeperator.len - (2 + item.result.hex.len + item.result.dec.len));
        try std.fmt.format(writer, "({s}){s}", .{ item.result.hex, item.result.dec });
        if (idx == selection) {
            //try std.fmt.format(writer, " =>", .{});
        }
        try std.fmt.format(writer, "{s}", .{lineEnd});
    }
    try std.fmt.format(writer, "{s}\n", .{lineSeperator});
}

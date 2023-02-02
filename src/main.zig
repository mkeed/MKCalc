const std = @import("std");
const draw = @import("Draw.zig");
const execute = @import("execute.zig");
const REPL = @import("REPL.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    try REPL.run(alloc, .{});
}

// fn other() void {
//     const items = [_]draw.DrawItem{
//         .{
//             .equation = "10 + 1",
//             .result = .{
//                 .dec = "11",
//                 .hex = "0xA",
//                 .binary = &.{ true, false, true, false },
//             },
//         },
//         .{
//             .equation = "12 + 01 + 0x1F + 0b0110 ",
//             .result = .{
//                 .dec = "13",
//                 .hex = "0xB",
//                 .binary = &.{ true, false, true, true },
//             },
//         },
//         .{
//             .equation = "12 + min(01,0x1F)",
//             .result = .{
//                 .dec = "13",
//                 .hex = "0xB",
//                 .binary = &.{ true, false, true, true },
//             },
//         },
//     };

//     try draw.DrawScreen(&items, .{ .rows = 20, .cols = 64 }, 0, stdout);
//     var file = try std.fs.cwd().createFile("main.c", .{});
//     defer file.close();
//     try execute.c_code(file.writer());
//     for (items) |item| {
//         _ = try execute.execute(item.equation, alloc);
//     }
// }
test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

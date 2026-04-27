const std = @import("std");
const c = @cImport({
    @cInclude("aptos_confidential_asset.h");
});

pub fn main() void {
    const solver = c.confidential_asset_create_solver();
    defer c.confidential_asset_free_solver(solver);

    var y: [32]u8 = undefined;
    @memset(&y, 0);

    const res = c.confidential_asset_solver_solve(solver, &y, y.len, 16);
    defer c.confidential_asset_free_buffer(res.value);
    defer c.confidential_asset_free_buffer(res.@"error");

    if (res.@"error".len != 0) {
        std.debug.print("solver error (len={})\n", .{res.@"error".len});
        return;
    }
    std.debug.print("discrete-log demo OK (result len={})\n", .{res.value.len});
}

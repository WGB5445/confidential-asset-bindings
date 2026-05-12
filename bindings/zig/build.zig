const std = @import("std");

/// Link the prebuilt Rust staticlib (`cargo build -p aptos_confidential_asset_ffi --release`).
/// Requires Zig 0.16+ (build API uses `root_module`).
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "aptos-confidential-asset-zig-demo",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    exe.root_module.addLibraryPath(b.path("../../rust/target/release"));
    exe.root_module.linkSystemLibrary("aptos_confidential_asset_ffi", .{});
    exe.root_module.addIncludePath(b.path("../../rust/ffi/include"));

    b.installArtifact(exe);

    const run_step = b.step("run", "Run demo");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());
}

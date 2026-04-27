const std = @import("std");

/// Link the prebuilt Rust staticlib (`cargo build -p aptos_confidential_asset_ffi --release`).
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "aptos-confidential-asset-zig-demo",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.addLibraryPath(b.path("../../rust/target/release"));
    exe.linkSystemLibrary("aptos_confidential_asset_ffi");
    exe.linkLibC();
    exe.addIncludePath(b.path("../../rust/ffi/include"));

    b.installArtifact(exe);

    const run = b.step("run", "Run demo");
    const run_exe = b.addRunArtifact(exe);
    run.dependOn(&run_exe.step);
}

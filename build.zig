const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    addExperiment(b, target, optimize, .{
        .name = "1-basic-window",
        .source_file = "src/1_basic_window.zig",
        .description = "Run experiment 1-basic-window",
    });
    addExperiment(b, target, optimize, .{
        .name = "2-create-file",
        .source_file = "src/2_create_file.zig",
        .description = "Run experiment 2-create-file",
    });
}

const Experiment = struct {
    name: []const u8,
    source_file: []const u8,
    description: []const u8,
};

fn addExperiment(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, exp: Experiment) void {
    const exe = b.addExecutable(.{
        .name = exp.name,
        .root_source_file = .{ .path = exp.source_file },
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step(exp.name, exp.description);
    run_step.dependOn(&run_cmd.step);
}

const std = @import("std");
const builtin = @import("builtin");
const os = std.os;
const log = std.log;
const fs = std.fs;
const w32 = @import("vendor/zigwin32/win32.zig").everything;

const TRUE: w32.BOOL = 1;
const FALSE: w32.BOOL = 0;

fn windowProc(handle: w32.HWND, msg: u32, wparam: w32.WPARAM, lparam: w32.LPARAM) callconv(.C) w32.LRESULT {
    switch (msg) {
        w32.WM_DESTROY => {
            w32.PostQuitMessage(0);
            return 0;
        },
        w32.WM_PAINT => {
            var paint = w32.PAINTSTRUCT{
                .rcPaint = w32.RECT{
                    .left = 0,
                    .top = 0,
                    .right = 0,
                    .bottom = 0,
                },
                .fErase = TRUE,
                .hdc = null,
                .fRestore = FALSE,
                .fIncUpdate = FALSE,
                .rgbReserved = std.mem.zeroes([32]u8),
            };
            const hdc = w32.BeginPaint(handle, &paint);
            _ = w32.FillRect(hdc, &paint.rcPaint, w32.GetStockObject(w32.WHITE_BRUSH));
            _ = w32.EndPaint(handle, &paint);
            return 0;
        },
        else => {
            return w32.DefWindowProcW(handle, msg, wparam, lparam);
        },
    }
}

pub fn main() !u8 {
    const h_instance = w32.GetModuleHandleW(null);
    const class_name = w32.L("My window class");

    const window_class = w32.WNDCLASSW{
        .style = w32.WNDCLASS_STYLES{
            .HREDRAW = 1,
            .VREDRAW = 1,
        },
        .lpfnWndProc = windowProc,
        .hInstance = h_instance,
        .hCursor = null,
        .hIcon = null,
        .hbrBackground = null,
        .lpszClassName = class_name,
        .lpszMenuName = null,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
    };
    _ = w32.RegisterClassW(&window_class);

    var style = w32.WS_OVERLAPPEDWINDOW;
    style.VISIBLE = 1;

    const hwnd = w32.CreateWindowExW(
        w32.WINDOW_EX_STYLE{},
        class_name,
        w32.L("Hello from zig"),
        style,
        w32.CW_USEDEFAULT,
        w32.CW_USEDEFAULT,
        640,
        480,
        null,
        null,
        h_instance,
        null,
    );

    if (hwnd == null) {
        switch (w32.GetLastError()) {
            else => {
                return 1;
            },
        }
    }

    // run message loop
    var msg = w32.MSG{
        .hwnd = null,
        .lParam = 0,
        .message = 0,
        .pt = w32.POINT{
            .x = 0,
            .y = 0,
        },
        .time = 0,
        .wParam = 0,
    };
    while (w32.GetMessageW(&msg, null, 0, 0) > 0) {
        _ = w32.TranslateMessage(&msg);
        _ = w32.DispatchMessageW(&msg);
    }

    return 0;
}

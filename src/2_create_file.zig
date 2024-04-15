const w32 = @import("vendor/zigwin32/win32.zig").everything;
pub fn main() !void {
    const filename = w32.L("C:\\Users\\Sam\\test.txt");
    const file_h = w32.CreateFileW(
        filename,
        w32.FILE_GENERIC_WRITE,
        w32.FILE_SHARE_NONE,
        null,
        w32.CREATE_ALWAYS,
        w32.FILE_ATTRIBUTE_NORMAL,
        null,
    );
    if (file_h == w32.INVALID_HANDLE_VALUE) {
        switch (w32.GetLastError()) {
            w32.ERROR_FILE_NOT_FOUND => {
                w32.OutputDebugStringW(w32.L("File not found\n"));
                return error.FileNotFound;
            },
            w32.ERROR_ACCESS_DENIED => {
                w32.OutputDebugStringW(w32.L("Access denied\n"));
                return error.AccessDenied;
            },
            else => {
                w32.OutputDebugStringW(w32.L("Unknown error\n"));
                return error.FailedToCreateFile;
            },
        }
    }
    defer if (w32.CloseHandle(file_h) == 0) {
        w32.OutputDebugStringW(w32.L("Failed to close file handle\n"));
    };

    const data = w32.L("Hello, World!\n");
    const bytes_to_write = data.len * 2; // data.len * 2 because in UTF-16 each character is 2 bytes
    var bytes_written: u32 = 0;
    if (w32.WriteFile(file_h, data, bytes_to_write, &bytes_written, null) == 0) {
        w32.OutputDebugStringW(w32.L("Failed to write to file\n"));
        return error.FailedToWriteToFile;
    }
    if (w32.FlushFileBuffers(file_h) == 0) {
        w32.OutputDebugStringW(w32.L("Failed to flush file buffers\n"));
        return error.FailedToFlushFileBuffers;
    }
}

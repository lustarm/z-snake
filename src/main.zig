const std = @import("std");
const print = std.debug.print;

const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});

const MAX_BLOCKS = 5000;

const Snake = struct {
    head: Block,
    length: i32,
    body: std.ArrayList,

    fn spawn(x: i32, y: i32) !Snake {
        const b: Block = Block{ .x = x, .y = y};

        var blocks: [MAX_BLOCKS]Block = try std.ArrayList(Block);

        // ! pre-define the 1st
        blocks[0].x = x;
        blocks[0].y = y;
        blocks[0].spawn();

        for (1..5) |i| {
            blocks[i].x = x + i;
            blocks[i].y = y + i;

            blocks[i].spawn();
        }

        // add asserts here later

        return Snake {
            .length = 5,
            .head = b,
            .body = blocks,
        };
    }
};

const Block = struct {
    x: i32,
    y: i32,

    fn spawn(x: i32, y: i32) !Block {
        print("spawning block\n", .{});

        return Block {
            .x = x,
            .y = y,
        };
    }
};

pub fn main() !void {
    // ! init
    if(sdl.SDL_Init(sdl.SDL_INIT_EVERYTHING) != 0) {
        sdl.SDL_Log("Unable to initalize SDL: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer sdl.SDL_Quit();

    // ! window
    const win = sdl.SDL_CreateWindow("z-snake", sdl.SDL_WINDOWPOS_CENTERED, sdl.SDL_WINDOWPOS_CENTERED, 140, 400, sdl.SDL_WINDOW_OPENGL)
    orelse {
        sdl.SDL_Log("Unable to create window: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    };

    defer sdl.SDL_DestroyWindow(win);

    // ! renderer
    const r = sdl.SDL_CreateRenderer(win, -1, 0)
    orelse {
        sdl.SDL_Log("Unable to create renderer: %s", sdl.SDL_GetError());
        return error.SDLInitializationFailed;
    };

    defer sdl.SDL_DestroyRenderer(r);

    var quit = false;
    while(!quit) {
        var e: sdl.SDL_Event = undefined;

        while(sdl.SDL_PollEvent(&e) != 0) {
            switch (e.type) {
                sdl.SDL_QUIT => {
                    quit = true;
                },
                else => {} // ! do nothing
            }
        }
    }
}


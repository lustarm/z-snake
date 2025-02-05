const std = @import("std");
const print = std.debug.print;

const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});

const MAX_BLOCKS = 5000;

const Block = struct {
    x: i32,
    y: i32,

    pub fn render(r: *sdl.SDL_Renderer, b: Block) !void {
        sdl.SDL_RenderDrawRect(r, b.x, b.y, 20, 20);
    }
};

const Snake = struct {
    head: Block,
    length: i32,
    body: []Block,

    const Self = @This();

    pub fn spawn(x: i32, y: i32, blocks: []Block) !Snake {
        // ! pre-define the 1st
        blocks[0].x = x;
        blocks[0].y = y;

        for (1..5) |i| {
            // *****
            blocks[i].x = x + @as(i32, @intCast(i));
            blocks[i].y = y;
        }

        return Snake {
            .length = 5,
            .head = blocks[0],
            .body = blocks,
        };
    }

    pub fn render(self: Self, r: *sdl.SDL_Renderer) !void {
        for(0..5) |i| {
            self.body[i].render(r);
        }
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

    // ! create allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const a = gpa.allocator();
    const blocks = try a.alloc(Block, MAX_BLOCKS);

    defer {
        a.free(MAX_BLOCKS);
        gpa.deinit();
    }

    // ! create snake
    const snake: Snake = try Snake.spawn(10, 10, blocks);

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

        _ = sdl.SDL_RenderClear(r);
        try snake.render(r);
        sdl.SDL_RenderPresent(r);

        sdl.SDL_Delay(5);
    }
}


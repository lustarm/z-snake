const std = @import("std");
const print = std.debug.print;

const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});

const MAX_BLOCKS = 5000;

const HEIGHT = 400;
const WIDTH = 300;

const Direction = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
};

const Tile = struct {
    apple: bool,
};

const Map = struct {
    tiles: []Tile,
};

const Block = struct {
    x: i32,
    y: i32,

    pub fn render(_: *Block, r: *sdl.SDL_Renderer, b: *Block, i: u32) !void {
        var head = false;

        if (i == 0) head = true;

        const rect = sdl.SDL_Rect {
            .h = 15,
            .w = 15,
            .x = b.x,
            .y = b.y,
        };

        if(i == 0) _ = sdl.SDL_SetRenderDrawColor(r, 0, 255, 0, 255)
        else _ = sdl.SDL_SetRenderDrawColor(r, 255, 0, 0, 255);

        _ = sdl.SDL_RenderFillRect(r, &rect);
        _ = sdl.SDL_RenderDrawRect(r, &rect);
        _ = sdl.SDL_SetRenderDrawColor(r, 0, 0, 0, 255);
    }
};

const Snake = struct {
    head: Block,
    length: i32,
    body: []Block,
    dir: Direction,

    pub fn spawn(x: i32, y: i32, blocks: []Block) !Snake {
        // ! pre-define the 1st
        blocks[0].x = x;
        blocks[0].y = y;

        for (1..5) |i| {
            // *****
            blocks[i].x = x + @as(i32, @intCast(i)) * 20;
            blocks[i].y = y;
        }

        return Snake {
            .length = 5,
            .head = blocks[0],
            .body = blocks,
            .dir = Direction.DOWN,
        };
    }

    pub fn render(self: *Snake, r: *sdl.SDL_Renderer) !void {
        for(0..5) |i| {
            switch(self.dir) {
                Direction.DOWN => self.body[i].y += 2,
                Direction.UP => self.body[i].y -= 2,
                Direction.RIGHT => self.body[i].x += 2,
                Direction.LEFT => self.body[i].x -= 2,
            }
            try self.body[i].render(r, &self.body[i], @intCast(i));
        }
    }

    pub fn input(_: *Snake) !void {

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
    const win = sdl.SDL_CreateWindow("z-snake", sdl.SDL_WINDOWPOS_CENTERED, sdl.SDL_WINDOWPOS_CENTERED, 300, 400, sdl.SDL_WINDOW_OPENGL)
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
    defer _ = gpa.deinit();

    const a = gpa.allocator();
    const blocks = try a.alloc(Block, MAX_BLOCKS);
    defer a.free(blocks);

    // ! create snake
    var snake: Snake = try Snake.spawn(10, 10, blocks);

    var quit = false;
    while(!quit) {
        var e: sdl.SDL_Event = undefined;

        while(sdl.SDL_PollEvent(&e) != 0) {
            switch (e.type) {
                sdl.SDL_QUIT => {
                    quit = true;
                },
                sdl.SDL_KEYDOWN => {
                    // change direction
                },
                else => {} // ! do nothing
            }
        }

        _ = sdl.SDL_RenderClear(r);
        try snake.render(r);
        try snake.input();
        sdl.SDL_RenderPresent(r);

        sdl.SDL_Delay(10);
    }
}


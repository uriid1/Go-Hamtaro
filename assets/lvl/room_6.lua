--
local room = new_room();

-- Setup
room.c_ghost    = 2;
room.c_monster  = 0;
room.c_fireBall = 2;
room.c_fireBall_v = 2;

room.name = "Level 5: Russia";
local background = sprite.russia;

-- Obj Player
local player = obj.player;
-- Create Map
room:init();

-- local's
local lg = love.graphics;
local map_canvas = lg.newCanvas(global.CANVAS_WIDTH, global.CANVAS_HEIGHT);
local mask_map   = lg.newCanvas(global.CANVAS_WIDTH, global.CANVAS_HEIGHT);
local outline_canvas = lg.newCanvas(global.CANVAS_WIDTH, global.CANVAS_HEIGHT);
--
local floor  = math.floor;
local ceil   = math.ceil;

-- Update Game
function room:update(dt)
    if (global.map_update == true) then
        -- Player
        player:step(dt);

        -- Enemy Move
        local c_dead = 0;
        for i = #enemy_instances, 1, -1 do
            local enemy = enemy_instances[i];
            enemy:step(dt);
            
            if (enemy.destroy == true) then
                instance_destroy(enemy_instances, i);
                if (enemy.type ~= enemy.types.ghost) then
                    c_dead = c_dead + 1;
                end
            end
        end
        if (c_dead >= 1) then
            sound.unlock_big:play();

            -- Если убили больше 2х, то +1 жизнь
            if (c_dead >= 2) then
                global.lives = global.lives + floor(c_dead/2);
            end
        end

        -- MAP CANVAS
        lg.setCanvas{map_canvas, stencil=true};
            lg.clear();
            lg.setColor(1, 1, 1, global.MAP_ALPHA);
            for y = 0, global.MAP_HEIGHT do
                for x = 0, global.MAP_WIDTH do
                    if (self.grid[y][x] == 0) then
                        lg.rectangle("fill", x * global.tile_size, y * global.tile_size, global.tile_size, global.tile_size);
                    end
                end
            end
        lg.setCanvas();

        -- Outline
        lg.setCanvas(outline_canvas);
            lg.clear();
            shader.outline:send('stepSize', {2 / global.CANVAS_WIDTH, 2 / global.CANVAS_HEIGHT});
            lg.setShader(shader.outline);
                lg.draw(map_canvas);
            lg.setShader();
        lg.setCanvas();

        -- Map Canvas
        lg.setColor(1, 1, 1, 1);
        lg.setCanvas(mask_map);
            lg.clear();
            self:draw_map();
        lg.setCanvas();
    end
end

-- foreground_texture
local foreground_texture = love.graphics.newCanvas(global.CANVAS_WIDTH, global.CANVAS_HEIGHT);

local w = sprite.fg:getWidth();
local h = sprite.fg:getHeight();
love.graphics.setCanvas({foreground_texture, stencil = true});
    love.graphics.clear();
    love.graphics.setColor(1, 1, 1, 1);
    for x = 0, global.CANVAS_WIDTH / w do
        for y = 0, global.CANVAS_HEIGHT / h do
            love.graphics.draw(sprite.fg, x * w, y * h);
        end
    end
love.graphics.setCanvas();

-- Drawing game
background:setFilter("linear", "linear");
local bg_w = background:getWidth();
local bg_h = background:getHeight();
local bg_xoffset = bg_w / 2;
local bg_yoffset = bg_h / 2;

local sw, sh = 1, 1;

-- Bakground
if (bg_h > global.CANVAS_HEIGHT) then
    sh = global.CANVAS_HEIGHT / bg_h;
    sw = sh;
else 
    sh, sw = 1, 1;
end

local game = lg.newCanvas(global.CANVAS_WIDTH, global.CANVAS_HEIGHT);
function room:draw_game()
    lg.setBackgroundColor(hex("493689ff"));
    --
    -- Main bg image
    lg.setColor(1, 1, 1, 1);
    lg.draw(background, global.CANVAS_XOFFSET, global.CANVAS_YOFFSET, 0, sw, sh, bg_xoffset, bg_yoffset);

    -- Texture
    lg.draw(mask_map);

    -- Stencil
    lg.stencil(function()
        lg.setShader(shader.mask);
        lg.draw(map_canvas);
        lg.setShader();
    end, "replace", 1);

    -- Foreground insert
    lg.setStencilTest("greater", 0)
        lg.setColor(1, 1, 1, global.MAP_ALPHA);
        lg.draw(foreground_texture);
    lg.setStencilTest();

    -- OutLine Map
    lg.setColor(1, 1, 1, global.MAP_ALPHA);
    lg.draw(outline_canvas);

    -- UI
    ---- Sclice borders
    lg.setColor(1, 1, 1, 1);
    draw_sclice(sprite.slice_game, sheet.slice_game, 0, 0, global.CANVAS_WIDTH, global.CANVAS_HEIGHT, 1);

    -- Player
    player:draw_self();
    player.image_alpha = global.MAP_ALPHA;

    -- Enemy
    for i = #enemy_instances, 1, -1 do
        local enemy = enemy_instances[i];
        enemy.image_alpha = global.MAP_ALPHA;
        enemy:draw_self();
    end
end


local border_space = 24;
local rainbow_scale = 0;
local percent = 0;
local div_empty_fill = 0;
local tmp_percent = 0;
function room:draw()
    --
    if (global.map_draw == true) then
        lg.setFont(font.game);
        -- UI
        lg.setColor(1, 1, 1, 1);
        draw_sclice(sprite.slice_all, sheet.slice_all, 0, 0, global.CANVAS_WIDTH, global.header_y + sheet.slice_all.h, 1);
        -- Face
        lg.draw(sprite.face, border_space + 25, 25);
        div_empty_fill = (global.map_empty / global.map_fill);

        -- 
        if (tmp_percent ~= div_empty_fill) then
            -- Если съедаем больше 20% добавлем жизнь
            if (div_empty_fill - tmp_percent) * 100  >= 15 then
                global.lives = global.lives + 1;
            end
            tmp_percent = div_empty_fill;
        end
        
        percent = lerp(percent, div_empty_fill * 100, 10 * dt);

        -- Lives
        lg.print("X"..global.lives, border_space + 25 + sprite.face:getWidth() + 10, 40);
        --
        lg.setLineWidth(2);
        lg.setColor(1, 1, 1, 1);
        rainbow_scale = lerp(rainbow_scale, (global.CANVAS_WIDTH - (300+border_space)) * div_empty_fill, 10 * dt);
        lg.draw(sprite.rainbow, 250, 26, 0, rainbow_scale, 1);
        lg.setColor(1, 1, 1, 0.75);
        lg.rectangle("line", 250, 25, global.CANVAS_WIDTH - (300+border_space), 54);
        lg.setColor(1, 1, 1, 1);
        lg.print(ceil(percent) .. "%", 260, 38);
        lg.setLineWidth(1);

        -- Game
        lg.push();
        lg.translate(0, global.header_y)
            self:draw_game();
            new_room:draw();
        lg.pop();
    else
        -- Это исправляет багу с 1% после game over
        percent = 0;
    end

    -- Stage Clear
    global.stage_clear = (ceil(div_empty_fill * 100) >= 80) and true or false;
    stage_clear(self.index + 1, global.stage_clear);

    -- Game Over
    global.game_over = global.lives < 0;
    game_over(self, global.game_over);
end

return room
--
room_game = new_room()

-- Create Map
room_game:init();

-- local's
local lg = love.graphics;
local map_canvas = lg.newCanvas(global.CANVAS_WIDTH, global.CANVAS_HEIGHT);
local mask_map = lg.newCanvas(global.CANVAS_WIDTH, global.CANVAS_HEIGHT);

-- Obj
local player = obj.player;

-- All init
player:init();
player.xoffset = player.xoffset - global.tile_size * 0.5;
player.yoffset = player.yoffset - global.tile_size * 0.5;

-- Enemy Setup
enemy_instances = {};
-- Create Enemy
for i = 1, 4 do
    local enemy = obj.enemy("ghost");
    enemy.x = math.random(global.tile_size*2, global.CANVAS_WIDTH  - global.tile_size * 2);
    enemy.y = math.random(global.tile_size*2, global.CANVAS_HEIGHT - global.tile_size * 2);
    enemy.dx = choose(1, -1);
    enemy.dy = choose(1, -1);
    table.insert(enemy_instances, enemy);
end

-- Update Game
function room_game:update(dt)
	if (global.stage_clear == false) then
	    player:step(dt);

	    -- Enemy Move
	    for i = #enemy_instances, 1, -1 do
	        enemy_instances[i]:step(dt);
	        if enemy_instances[i].destroy then
	        	instance_destroy(enemy_instances, i)
	        end
	    end

	    -- MAP CANAS
		lg.setCanvas({map_canvas, stencil = false});
		lg.clear();
		for y = 0, global.MAP_HEIGHT do
	   		for x = 0, global.MAP_WIDTH do
	   			if (room_game.grid[y][x] == 0) then
	            	lg.rectangle("fill", x * global.tile_size, y * global.tile_size, global.tile_size, global.tile_size);
	   			end
	   		end
	   	end
		lg.setCanvas();

		-- Outline Map Canvas
		lg.setCanvas(mask_map);
			lg.clear();
			room_game:draw_map();
		lg.setCanvas();
	end
end


-- foreground_texture
local foreground_texture = lg.newCanvas(global.CANVAS_WIDTH, global.CANVAS_HEIGHT);

local w = sprite.fg:getWidth();
local h = sprite.fg:getHeight();
lg.setCanvas({foreground_texture, stencil = true});
	lg.clear();
	for x = 0, global.CANVAS_WIDTH / w do
		for y = 0, global.CANVAS_HEIGHT / h do
			lg.draw(sprite.fg, x * w, y * h);
		end
	end
lg.setCanvas();

-- Drawing game
sprite.london:setFilter("linear", "linear");
local bg_w = sprite.london:getWidth();
local bg_h = sprite.london:getHeight();
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
function draw_game()
	lg.push();
	lg.translate(0, 90)
		lg.setBackgroundColor(hex("493689ff"));
		--
		lg.setColor(1, 1, 1, 1);
		lg.draw(sprite.london, global.win_xoffset, global.win_yoffset - 45, 0, sw, sh, bg_xoffset, bg_yoffset);

		--
		room_game:draw_map();

		--
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

		-- Mask Map
		if (global.stage_clear == false) then
			shader.outline:send('stepSize', {2 / global.CANVAS_WIDTH, 2 / global.CANVAS_HEIGHT});
			lg.setShader(shader.outline);
				lg.draw(mask_map);
			lg.setShader();
		end

		-- UI
		---- Sclice borders
		lg.setColor(1, 1, 1, 1);
		draw_sclice(sprite.slice_game, sheet.slice_game, 0, 0, global.CANVAS_WIDTH, global.CANVAS_HEIGHT, 1);

		-- Player
		player:draw_self();
		player.image_alpha = global.MAP_ALPHA;

	    -- Enemy
	    for i = #enemy_instances, 1, -1 do
	    	enemy_instances[i].image_alpha = global.MAP_ALPHA;
	        enemy_instances[i]:draw_self();
	    end

		-- Debug
		if (global.debug == true) then
			lg.setColor(1, 1, 1, 1);
			-- Grid
		    for y = 0, global.MAP_HEIGHT - 1 do
		        for x = 0, global.MAP_WIDTH - 1 do
		          lg.setColor(1, 1, 1, 0.05);
		          lg.rectangle("line", x*global.tile_size, y*global.tile_size, global.tile_size, global.tile_size)
		        end
		    end

			lg.setFont(font.small);
			lg.print("FPS: " .. love.timer.getFPS(), 10, 5);
			lg.print("DIR: " .. player.dir, 10, 30);

			if (player.current_move == player.move_in_ground) then
				lg.print("IN GROUND", 10, 55);
			else
				lg.print("IN EMPTY", 10, 55);
			end
		end
	lg.pop();
end

local sc_size = 0;
local sc_rotate = 0;
local sc_alpha = 1;
local sc_timer = 0;
function stage_clear()
	sc_size = lerp(sc_size, 100, 0.05);
	sc_rotate = lerp(sc_rotate, 360, 0.075);
	sc_timer = sc_timer + dt;

	if sc_timer >= 3 then
		sc_alpha = lerp(sc_alpha, 0, 0.05);
		global.MAP_ALPHA = lerp(global.MAP_ALPHA, 0, 0.05);
	end

	lg.setColor(1, 1, 1, sc_alpha);
	lg.draw(sprite.stage_clear, (global.CANVAS_WIDTH*0.5), (global.CANVAS_HEIGHT*0.5) + 90, math.rad(sc_rotate), sc_size/100, sc_size/100, sprite.stage_clear:getWidth()*0.5, sprite.stage_clear:getHeight()*0.5);
end

local border_xspace = 24;
local rainbow_scale = 0;
local percent = 0;
function room_game:draw()

	lg.setFont(font.game);
	-- UI
	lg.setColor(1, 1, 1, 1);
	draw_sclice(sprite.slice_all, sheet.slice_all, 0, 0, global.CANVAS_WIDTH, 115, 1);
	-- Face
	lg.draw(sprite.face, border_xspace + 25, 25);
	local div_empty_fill = (global.map_empty / global.map_fill);
	percent = lerp(percent, div_empty_fill * 100, 0.1);
	-- Lives
	lg.print("X"..global.live, border_xspace + 25 + sprite.face:getWidth() + 10, 40);
	--
	lg.setLineWidth(2);
	lg.setColor(1, 1, 1, 1);
	rainbow_scale = lerp(rainbow_scale, (global.CANVAS_WIDTH - (300+border_xspace)) * div_empty_fill, 0.1);
	lg.draw(sprite.rainbow, 250, 26, 0, rainbow_scale, 1);
	lg.setColor(1, 1, 1, 0.75);
	lg.rectangle("line", 250, 25, global.CANVAS_WIDTH - (300+border_xspace), 54);
	lg.setColor(1, 1, 1, 1);
	lg.print(math.ceil(percent) .. "%", 260, 38);
	lg.setLineWidth(1);

	-- Game
	draw_game();

	-- Stage Clear
	global.stage_clear = (math.ceil(percent) >= 80) and true or false;
	if (global.stage_clear == true) then
		stage_clear()
	end
end
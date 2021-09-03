io.stdout:setvbuf("no");

function love.load()
	------------  LIBS  ------------
	serialize = require "libs.serialize";
	audio = require "libs.wave";
	class = require "libs.class";

	simple_scale = require "libs.simpleScale";
	local sw = 720;
	local sh = 810;
	simpleScale.setWindow(sw, sh, sw, sh, {fullscreen = false, resizable = true});
	love.graphics.setDefaultFilter("nearest", "nearest");
	--love.graphics.setDefaultFilter("linear", "linear");
	-- lovebird = require("libs/lovebird");

	------------ ENGINE ------------
	require "engine.object";
	require "engine.engine";
	require "engine.collision";
	require "engine.sheet";
	require "engine.room";
	require "engine.easing";

	-- Delta time
	dt = 1 / 60;
	global.fps = love.timer.getFPS();
	
	-- For Mobile's
	if (love.system.getOS() == "Android" or love.system.getOS() == "Ios") then
		global.os = "mobile";
		love.window.setFullscreen(true);
	else
		global.os = "pc";
		-- love.window.setIcon(love.image.newImageData("icon.png"));
	end

	-- Load rooms
	require("assets/lvl/lvl_0");

	-- Current room
	current_room = room_loading;
end

function love.update()
	mouse_x, mouse_y = love.mouse.getPosition();

	-- dt
	global.fps = love.timer.getFPS();
	if global.fps == round(1.0 / love.timer.getDelta()) then
		dt = 1 / global.fps;
	end

	current_room:update(dt);
	--lovebird.update();

	simple_scale.resizeUpdate();
end

function love.draw()
	if (current_room == room_loading) then
		current_room:draw();
	else
		-- Game Draw
		simple_scale.set();
	    current_room:draw();
	   	simple_scale.unSet();
	end
end
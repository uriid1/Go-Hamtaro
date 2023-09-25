---------------- RESOURSE ----------------
-- Win
global.win_w = love.graphics.getWidth();
global.win_h = love.graphics.getHeight();
global.win_xoffset = global.win_w*.5;
global.win_yoffset = global.win_h*.5;

-- Default
global.filter = "nearest";
global.fps    = 60;
global.debug  = false;
global.delta  = 0;
global.sin    = 0;

-- Game
global.lives = 3;
global.room_index = 2;

-- Enemy Setup
enemy_instances = {};

-- Check and format resource
local function fmt_res_name(name)
	-- return type, name, format
	return name:match("(%a-_)(.+)(%..+)");
end

-- Check exists directory
local function directory_exists(dir)
	if (love.filesystem.getInfo(dir) == nil) then
		print("Не существует директории " .. dir);
		return false;
	end
	return true;
end

-- If all directory exists
if not directory_exists("assets/snd/") or not directory_exists("assets/spr/") or
   not directory_exists("assets/obj/") or not directory_exists("assets/lvl/")
then
	love.event.quit();
end

-- Get Directory Items
local music_list_in_folder  = love.filesystem.getDirectoryItems("assets/snd/");
local sprite_list_in_folder = love.filesystem.getDirectoryItems("assets/spr/");
local obj_list_in_folder    = love.filesystem.getDirectoryItems("assets/obj/");
local lvl_list_in_folder    = love.filesystem.getDirectoryItems("assets/lvl/");

print "*** Music and Sounds ***";
music = {}	-- music_
sound = {}	-- snd_
for i, filename in ipairs(music_list_in_folder) do
	--
	local type, name, format = fmt_res_name(filename);

	-- Music
	if (type == "music_") then
		if (name == nil) then
			print("Неверное имя у - assets/snd/" .. filename);
			goto continue;
		end
		print("Load: assets/snd/"..filename);
		music[name] = audio:newSource("assets/snd/"..filename, "stream");
		goto continue;
	end

	-- Sound
	if (type == "snd_") then
		if (name == nil) then
			print("Неверное имя у - assets/snd/" .. filename);
			goto continue;
		end
		print("Load: assets/snd/"..filename);
		sound[name] = audio:newSource("assets/snd/"..filename, "static");
		goto continue;
	end
	
	-- If error
	print("Неверное имя у - assets/snd/" .. filename);

	::continue::
end
print "\n"

-- Apply config
local function set_conf(sname)
	-- If find conf == spr name or sprSheet name
	for k, v in pairs(conf) do
		if (k == sname) then
			-- Cut spriteSheet
			if (conf[sname].cut == true) then
				-- Cut..
				sheet[sname] = cut_sheet(sprite[sname], conf[sname].cut_w, conf[sname].cut_h, (conf[sname].cut_nx * conf[sname].cut_ny) - conf[sname].cut_diff, conf[sname].cut_nx, conf[sname].cut_ny);
				-- Set speed
				sheet[sname].animation_speed = conf[sname].anim_speed;
				sheet[sname].image_speed     = conf[sname].anim_speed; -- / global.fps;
				-- Set animation type
				sheet[sname].animation_type = conf[sname].anim_type;
			end
		end
	end
end

print "*** Sprite and Sheet + Config ***";
sprite = {}	-- spr_
sheet = {}	-- sheet_
conf = {}	-- conf_

for i, filename in ipairs(sprite_list_in_folder) do
	--
	local type, name, format = fmt_res_name(filename);

	-- Config
	if (type == "conf_") then
		if (name == nil) then
			print("Неверное имя assets/spr/" .. filename);
			goto continue;
		end
		-- Deserialize config
		print("Load: assets/spr/" .. filename);
		conf[name] = serialize.load("assets/spr/" .. filename);
		goto continue;
	end

	-- Sprite
	if (type == "spr_") then
		if (name == nil) then
			print("Неверное имя assets/spr/" .. filename);
			goto continue;
		end
		print("Load: assets/spr/" .. filename);
		sprite[name] = love.graphics.newImage("assets/spr/" .. filename);
		goto continue;
	end

	-- spriteSheet
	if (type =="sheet_") then
		if (name == nil) then
			print("Неверное имя assets/spr/" .. filename);
			goto continue;
		end
		print("Load: assets/spr/" .. filename);
		sprite[name] = love.graphics.newImage("assets/spr/" .. filename);
		set_conf(name);
		goto continue;
	end

	-- If error
	print("Неверное имя assets/spr/" .. filename);

	::continue::
end
print "\n"

-- all
set_filter(sprite, "linear");
-- Исключения
sprite.slice_all:setFilter("nearest", "nearest");
sprite.slice_game:setFilter("nearest", "nearest");
--

print "*** Objects ***"
obj = {}
for i, filename in ipairs(obj_list_in_folder) do
	--
	local type, name, format = fmt_res_name(filename);
	--
	if (name == nil) then
		print("Неверное имя assets/obj/" .. filename);
	end
	print("Load: assets/obj_" .. filename);
	obj[name] = require ("assets/obj/obj_"..name);
	obj[name].name = obj_name;
end
print "\n"

print "*** Rooms ***";
room = {};
local l = 1; -- level index;
for i, filename in ipairs(lvl_list_in_folder) do
	if (filename:match("room") ~= nil) then
		local room_name = filename:gsub(".lua", "");
		print("Load: assets/lvl/" .. filename);
		if (room_name ~= "room_0") then -- room loading
			room[l] = require("assets/lvl/" .. room_name);
			room[l].index = l;
			l = l + 1;
		end
	end
end
print "\n"

-- Fonts
local list_font = {
	main  = "game.otf";
	menu  = 52;
	large = 42;
	small = 28;
	game  = 28;
}
-- load fonts
font = {};
for k, v in pairs(list_font) do
	if (k ~= "main") then
		font[k] = love.graphics.newFont('assets/fnt/'..list_font.main, v)
	end
end
set_filter(font, "linear");

--- Shaders
local list_shader = {
	"outline";
	"mask";
	"rainbow";
}
-- Load shaders
shader = {};
for _, v in pairs(list_shader) do
	shader[v] = love.graphics.newShader("assets/glsl/" .. v .. ".glsl");
end
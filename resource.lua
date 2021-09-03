---------------- RESOURSE ----------------
-- Win
global.win_w = love.graphics.getWidth();
global.win_h = love.graphics.getHeight();
global.win_xoffset = global.win_w*.5;
global.win_yoffset = global.win_h*.5;

-- Map
global.map_w = global.win_w;
global.map_h = global.win_h;
global.map_xoffset = global.map_w / 2;
global.map_yoffset = global.map_h / 2;
global.map_angle = 0;

-- Default
global.filter = "nearest";
global.fps = 60;
global.debug  = fasle;
global.delta  = 0;
global.sin    = 0;

-- Load Music and Sounds
music = {}	-- music_
sound = {}	-- snd_
--
local music_list_in_folder = love.filesystem.getDirectoryItems("assets/snd/"); -- in table
if (music_list_in_folder ~= nil) then
	for i, filename in ipairs(music_list_in_folder) do

		-- Music
		if filename:match("music_") then
			local music_name = filename:gsub("music_", "");
			local music_name = music_name:gsub(".mp3", "");
			local music_name = music_name:gsub(".ogg", "");
			local music_name = music_name:gsub(".wav", "");
			music[music_name] = audio:newSource("assets/snd/"..filename, "static");
			-- Sound
		elseif filename:match("snd_") then
			local music_name = filename:gsub("snd_", "");
			local music_name = music_name:gsub(".mp3", "");
			local music_name = music_name:gsub(".ogg", "");
			local music_name = music_name:gsub(".wav", "");
			sound[music_name] = audio:newSource("assets/snd/"..filename, "static");
		else
			print("Неверное имя у - assets/snd/" .. filename);
		end
		
	end
end

-- Load config
conf = {}
local conf_list_in_folder = love.filesystem.getDirectoryItems("assets/spr/");
if (conf_list_in_folder ~= nil) then
	for i, filename in ipairs(conf_list_in_folder) do
		if filename:match("conf_") then
			local conf_name = filename:gsub("conf_", "");
			local conf_name = conf_name:gsub(".tbl", "");

			-- Deserialize config
			conf[conf_name] = serialize.load("assets/spr/"..filename);
		end
	end
end

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
				sheet[sname].image_speed    = conf[sname].anim_speed / global.fps;
				-- Set animation type
				sheet[sname].animation_type = conf[sname].anim_type;
			end
		end
	end
end

-- Load sprite and spriteSheet
sprite = {}	-- spr_
sheet = {}	-- sheet_
--
local spr_list_in_folder = love.filesystem.getDirectoryItems("assets/spr/")
if (spr_list_in_folder ~= nil) then -- Загрузка спрайтов в таблицу
	for i, filename in ipairs(spr_list_in_folder) do
		if (filename:match("conf_") == nil) then

			-- Sorite
			if filename:match("spr_") then
				local spr_name = filename:gsub("spr_", "");
				local spr_name = spr_name:gsub(".png", "");
				local spr_name = spr_name:gsub(".jpg", "");
				sprite[spr_name] = love.graphics.newImage("assets/spr/"..filename);
				-- spriteSheet
			elseif filename:match("sheet_") then
				local quad_name = filename:gsub("sheet_", "");
				local quad_name = quad_name:gsub(".png", "");
				sprite[quad_name] = love.graphics.newImage("assets/spr/"..filename);
				set_conf(quad_name);
			else
				print("Неверное имя у - assets/spr/" .. filename );
			end

		end
	end
end

-- all
set_filter(sprite, "linear");
-- Исключения
sprite.slice_all:setFilter("nearest", "nearest");
sprite.slice_game:setFilter("nearest", "nearest");
--

-- Objects
obj = {}
local obj_list_in_folder = love.filesystem.getDirectoryItems("assets/obj/");
if (obj_list_in_folder ~= nil) then
	for i, filename in ipairs(obj_list_in_folder) do
		local obj_name = filename:gsub("obj_", "");
		local obj_name = obj_name:gsub(".lua", "");
		obj[obj_name] = require ("assets/obj/obj_"..obj_name);
		obj[obj_name].name = obj_name;
	end
end

-- Fonts
font = {};
font.score = love.graphics.newFont('assets/fnt/game.otf', 120);
font.large = love.graphics.newFont('assets/fnt/game.otf', 73);
font.small = love.graphics.newFont('assets/fnt/game.otf', 18);
font.game  = love.graphics.newFont('assets/fnt/game.otf', 28);
set_filter(font, "linear");

--- Shaders
shader = {};
-- Outline Sahder
shader.outline = love.graphics.newShader("assets/glsl/outline.glsl");
-- Mask шейдер для foreground
shader.mask = love.graphics.newShader("assets/glsl/mask.glsl");
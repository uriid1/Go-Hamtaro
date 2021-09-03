-- Это костыль для решения проблемы с почетом высоты устройств.
room_loading = new_room();

-- Load res
local lg = love.graphics;
local spr_micro = lg.newImage("assets/spr/spr_loading.png");
spr_micro:setFilter('nearest', 'nearest');

-- Debug resolution
local i = 0;
local debug_lvl = false;
function room_loading:update()

	i = i + 1;
	if (i >= 10) then 
		debug_lvl = true; 
	end

	if (debug_lvl == true) then
		-- Loading resource
		require("resource");

		-- loading rooms
		local lvl_list_in_folder = love.filesystem.getDirectoryItems("assets/lvl/");
		if (lvl_list_in_folder ~= nil) then
			for i, filename in ipairs(lvl_list_in_folder) do
				if (filename:match("lvl") ~= nil) then
					local lvl_name = filename:gsub(".lua", "");
					if (lvl_name ~= "lvl_0") then
						require("assets/lvl/"..lvl_name);
					end
				end
			end
		end

		-- goto next room
		room_goto(room_game);
	end
	
end

local fnt_small = lg.newFont('assets/fnt/game.otf', 30);
lg.setFont(fnt_small);
local loading = "Loading";
local dot_time = 0;
local dot_count = 0;

function room_loading:draw()
	-- Parse screen resolution
	global.win_w = lg.getWidth();
	global.win_h = lg.getHeight();
	global.win_xoffset = global.win_w * 0.5;
	global.win_yoffset = global.win_h * 0.5;

	local sx, sy;
	-- Parse Img main loadind
	local w_offset = spr_micro:getWidth() * 0.5;
	local h_offset = spr_micro:getHeight() * 0.5;

	if (global.win_w > global.win_h) then
		sy = math.floor(global.win_h / (spr_micro:getHeight() + 10));
		sx = sy;
	else
		sx = math.floor(global.win_w / (spr_micro:getWidth() + 15));
		sy = sx;
	end

	local mw = spr_micro:getWidth() * sx;
	local mh = spr_micro:getHeight() * sy;

	lg.setBackgroundColor(hex("3c84b5ff"));
	lg.draw(spr_micro, global.win_xoffset - mw * 0.5, global.win_yoffset - mh * 0.5, 0, sx, sy);
	
	lg.setColor(0, 0, 0, 0.5);	
	lg.rectangle("fill", 17, global.win_h - 61, fnt_small:getWidth(loading) + 17, 58)

	dot_time = (dot_time + 0.5) % 10;
	if (dot_time >= 9.5) then
		loading = loading .. ".";
		dot_count = dot_count + 1;
	end
	--print(dot_count)

	if (dot_count == 4) then
		loading = "Loading";
		dot_count = 0;
	end

	lg.setColor(1, 1, 1, 1);
	lg.print(loading, 25, global.win_h - 50);
end
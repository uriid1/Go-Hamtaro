
--
local pairs    = pairs;
local remove   = table.remove;
--
local tonumber = tonumber;
local tostring = tostring;
local lower    = string.lower;
local sub      = string.sub;
--
local pi       = math.pi;
local cos      = math.cos;
local sin      = math.sin;
local atan2    = math.atan2;
local sqrt     = math.sqrt;
local floor    = math.floor;
local ceil     = math.ceil;
local min      = math.min;
local max      = math.max;
local random   = math.random;
--
local lg = love.graphics; 

--- Const
math.randomseed(os.time());
_D2R = pi / -180;
_R2D = -180 / pi;

-- Global's
global = {}

-- Game
function game_save()
	if current_room then
		-- Create data
		local data = {};
		data.room_index = current_room.index;
		data.lives      = global.lives;
		
		-- Serialize
		serialize.save(data, "save0.sav");
	end
end

function check_save()
	return love.filesystem.getInfo("save0.sav");
end

function load_save()
	-- load and deserialize
	local data = serialize.load("save0.sav");
	
	-- Set
	global.lives      = data.lives;
	global.room_index = data.room_index;
end

-- Extra mathematical functions
function sign(x)
	return (x > 0) and 1 or (x == 0 and 0 or -1);
end

function round(x)
	return (x >= 0) and floor(x + 0.5) or ceil(x - 0.5);
end

function clamp(val, val_min, val_max)
	return max(val_min, min(val_max, val));
end

function range(val, val_min, val_max) 
	return val == max(val_min, min(val_max, val));
end

function lerp(v0, v1, t)
	return v0 * (1.0 - t) + t * v1;
end

-- Trig functions
function lengthdir_x(length, direction)
	return length * cos(direction * _D2R);
end

function lengthdir_y(length, direction)
	return length * sin(direction * _D2R);
end

function point_direction(x1, y1, x2, y2)
	return (_R2D * (atan2(y1 - y2, x1 - x2))) + 180;
end

function angle_difference(ang1, ang2)
	return ((((ang1 - ang2) % 360) + 540) % 360) - 180;
end

function distance_to_point(x1, y1, x2, y2) 
	return sqrt( (x1 - x2)^2 + (y1 - y2)^2 );
end

function degtorad(degree)
	return degree * _D2R;
end

function radtodeg(degree)
	return degree * _R2D;
end

-- Всратая Сортировка
function found_min(t)
    local first = t[1];
    for i = 1, #t do
        if first > t[i] then
            first = t[i]
        end
    end
    return first;
end

function found_max(t)
    local first = t[1];
    for i = 1, #t do
        if first < t[i] then
            first = t[i]
        end
    end
    return first;
end

-- GamePlay functions
key_mouse = {};
key_mouse.__index = key_mouse;
function key_mouse:init()
	-- init
	local obj = setmetatable({}, self);
	obj.pressed_time = 0;

	return obj;
end

function key_mouse:pressed(mpress)
	if (love.mouse.isDown(mpress)) then
		if (self.pressed_time == 0) then
	        self.pressed_time = 1;
	        return true;
	    end
	else
		self.pressed_time = 0;
		return false;
	end
end

-- Выбор одного значения из таблицы choose(-10, 10.23, "lol")
function choose(...)
    local t = {...};
    return t[random(#t)];
end

-- Нумерованный список num_list = enum()
function enum(...)
	local tmp = {};
	for k, v in pairs({...}) do
		tmp[v] = k;
	end
	return tmp;
end

-- Выбор по типу swith-case
function switch(case, tbl)
	if (tbl[case]) then
		tbl[case]();
		return;
	end

	if tbl["default"] then
		tbl["default"]();
	end
end

-- Полет объекта к точке
function move_towards_point(obj, to_x, to_y, spd)
    local dx = to_x - obj.x
    local dy = to_y - obj.y
    local dist = dx * dx + dy * dy;

    if (dist < spd * spd) then
        obj.x = to_x
        obj.y = to_y
    else
        dist = sqrt(dist)
        obj.x = obj.x + dx * spd / dist
        obj.y = obj.y + dy * spd / dist
    end
end

-- Удаление объекта в цикле
--- function instance_destroy(_obj, i)
--	remove(_obj, i);
-- end
instance_destroy = remove;

-- Функция возращает ключ "объекта" из таблицы которому соответствует заданный индекс
function get_key_from_index(tbl, fkey)
    for k, v in pairs(tbl) do
        if tbl[k].index == fkey then
            return k
        end
    end
end

--------- Color Функции ---------
-- В процентный формат
function rgba(r, g, b, a)
	return  r * 0.0039215686,
			g * 0.0039215686,
			b * 0.0039215686,
			a * 0.01
end

-- HEX в RGBA
function hex(hex_color)
	local lower_hex = lower(hex_color);
	return  tonumber("0x"..sub(lower_hex, 0, 2)) * 0.0039215686274,	-- R
			tonumber("0x"..sub(lower_hex, 3, 4)) * 0.0039215686274,	-- G
			tonumber("0x"..sub(lower_hex, 5, 6)) * 0.0039215686274,	-- B
			tonumber("0x"..sub(lower_hex, 7, 8)) * 0.0039215686274	-- A
end

-------- OOP
-- Наследование
function inherit(child, parent)
	setmetatable(child, {__index = parent});
end

-------- Slice
function draw_sclice(spr, quad, x1, y1, x2, y2)
	--
	local size = spr:getWidth() / 3;

	--
	local width  = x2 - x1;
	local height = y2 - y1;
	--
	local scale_w = (width  - size * 2) / size;
	local scale_h = (height - size * 2) / size;

	lg.draw(spr, quad.frames[5], x1 + size, y1 + size, 0, scale_w, scale_h);		-- midle
	--
	lg.draw(spr, quad.frames[4], x1, y1 + size, 0, 1, scale_h);						-- left edge
	lg.draw(spr, quad.frames[6], x1 + width - size, y1 + size, 0, 1, scale_h);		-- right edge
	lg.draw(spr, quad.frames[2], x1 + size, y1, 0, scale_w , 1);					-- top edge
	lg.draw(spr, quad.frames[8], x1 + size, y1 + height - size, 0, scale_w, 1);		-- bottom edge
	--
	lg.draw(spr, quad.frames[1], x1, y1, 0, 1, 1);							   	 	-- top left corner
	lg.draw(spr, quad.frames[3], x1 + width - size, y1, 0, 1, 1);			  	  	-- top right corner
	lg.draw(spr, quad.frames[7], x1, y1 + height - size, 0, 1, 1);			    	-- bottom left corner
	lg.draw(spr, quad.frames[9], x1 + width - size, y1 + height - size, 0, 1, 1); 	-- bottom right corner
end
--------

-------- Комнаты ---------
function room_goto(_room)
	-- collectgarbage("collect")
	current_room = _room
	if current_room.init then
		current_room:init(true);
	end
end

----------- Filter All
-- nearest / linear
function set_filter(tbl, filter)
	if (type(tbl) == "table") then
		for key, val in pairs(tbl) do
			if (type(val) == "userdata") then
				val:setFilter(filter, filter);
			else
				print("set_filter: не найден Font или Image.");
				return;
			end
		end
	else
		print("set_filter: передана не таблица.");
	end
end

-------- Debug Отрисовка --------
-- переписать
function draw_mask_outline(obj)
	lg.setLineWidth(1)
	lg.setColor(0, 1, 0, 1)

	if obj.mask.x ~= nil then
		lg.rectangle("line", (obj.x + obj.mask.x) - obj.mask.xoffset, (obj.y + obj.mask.y) - obj.mask.yoffset, obj.mask.w, obj.mask.h)
	else
		lg.rectangle("line", obj.x - obj.xoffset, obj.y - obj.yoffset, obj.w, obj.h)
	end
	lg.setColor(1, 1, 1, 1)
end

function draw_sprite_outline(_spr, _obj)
	lg.setColor(1, 1, 1, 1)
	local w = _spr:getWidth()
	local h = _spr:getHeight()
	local xoffset = w*.5
	local yoffset = h*.5
	lg.rectangle("line", _obj.x - xoffset, _obj.y - yoffset, w, h)
end

function draw_sheet_outline(_spr, _obj)
	lg.setColor(1, 1, 1, 1)
	lg.rectangle("line", _obj.x - _spr.frame_xoffset, _obj.y - _spr.frame_xoffset, _spr.frame_w, _spr.frame_h)
end
---------------------------------

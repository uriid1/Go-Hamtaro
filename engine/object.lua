-- Глобальный дефолтный класс
object = class:extend();
function object:newClass(spr_name, x, y, dir, spd)
	-- Свойства взаимодействия
	self.x = x or 0;
	self.y = y or 0;
	self.direction = dir or 0;
	self.speed = spd or 0;
	self.xstart = self.x;
	self.ystart = self.y;
	self.hspeed = 0;
	self.vspeed = 0;
	self.destroy = false;
	self.solid = false;

	-- Drawing
	self.draw = true;
	self.sprite_index = sprite[spr_name];
	--
	self.sheet = sheet[spr_name] or nil;
	self.image_index = 1;

	--
	if (self.sheet ~= nil) then
		self.w = self.sheet.w;
		self.h = self.sheet.h;
		self.xoffset = self.sheet.xoffset;
		self.yoffset = self.sheet.yoffset;
		self.image_number = self.sheet.image_number;
		self.image_speed  = self.sheet.image_speed;
		self.animation_type = self.sheet.animation_type;
	else
		self.w = self.sprite_index:getWidth()  or 1;
		self.h = self.sprite_index:getHeight() or 1;
		self.xoffset = self.w / 2;
		self.yoffset = self.h / 2;
		self.image_number = 1;
		self.image_speed  = 0;
		self.animation_type = "";
	end

	--
	self.animation_end = false;

	-- Пересчитываем свойства
	self.calc_sheet  = false;
	self.calc_sprite = false;

	---
	self.image_angle = 0;
	self.image_alpha = 1;
	self.xscale = 1;
	self.yscale = 1;

	-- Свойства масок коллизий
	self.mask = {};
	if (conf[spr_name] ~= nil) then 
		if (conf[spr_name].type == "rect") then
			self.mask.w = conf[spr_name].w;
			self.mask.h = conf[spr_name].h;
			self.mask.x = conf[spr_name].x;
			self.mask.y = conf[spr_name].y;
			self.mask.xoffset = conf[spr_name].xoffset;
			self.mask.yoffset = conf[spr_name].yoffset;
		else  -- Circe?
			self.mask.w = self.w;
			self.mask.h = self.h;
			self.mask.x = 0;
			self.mask.y = 0;
			self.mask.xoffset = self.xoffset;
			self.mask.yoffset = self.yoffset;
		end

		self.mask_type = conf[spr_name].type;
	else
		self.mask_type = "self";
		self.mask.w = self.w;
		self.mask.h = self.h;
		self.mask.x = 0;
		self.mask.y = 0;
		self.mask.xoffset = self.xoffset;
		self.mask.yoffset = self.yoffset;
	end
	self.solid = true;
end -- func

-- Step
local cos = math.cos;
local sin = math.sin;
function object:move()
	if (self.speed ~= 0) then
		local dir = self.direction * _D2R;
		self.hspeed = self.speed * cos(dir);
		self.vspeed = self.speed * sin(dir);
		self.x = self.x + self.hspeed;
		self.y = self.y + self.vspeed;
	end
end

-- Sprite draw
local draw      = love.graphics.draw;
local set_color = love.graphics.setColor;
function object:draw_self()
	set_color(1, 1, 1, self.image_alpha);
	if (self.draw == true) then
		if (self.sheet == nil) then
			--
			if (self.calc_sprite == true) then
				self.w = self.sprite_index:getWidth()  or 0;
				self.h = self.sprite_index:getHeight() or 0;
				self.xoffset = self.w / 2;
				self.yoffset = self.h / 2;
				self.image_number = 1;
				self.image_speed  = 0;
				self.calc_sprite = false;
			end
			--
			draw(self.sprite_index, self.x, self.y, self.image_angle * _D2R, self.xscale, self.yscale, self.xoffset, self.yoffset);
		else
			-- Перерасчет свойств
			-- В случае смены sprHeet
			if (self.calc_sheet == true) then
				self.xoffset = self.sheet.xoffset;
				self.yoffset = self.sheet.yoffset;
				self.w = self.sheet.w;
				self.h = self.sheet.h;
				self.image_number = self.sheet.image_number;
				self.image_speed  = self.sheet.image_speed / global.fps;
				self.animation_type = self.sheet.animation_type;
				self.calc_sheet = false;
			end
			--
			draw(self.sprite_index, self.sheet.frames[math.floor(self.image_index)], self.x, self.y, self.image_angle * _D2R, self.xscale, self.yscale, self.xoffset, self.yoffset);
		end
	end
	set_color(1, 1, 1, 1);
end
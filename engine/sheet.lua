function cut_sheet(spr, w, h, num, x, y)
	--
	local sheet = {};

    local width = spr:getWidth();
    local height = spr:getHeight();

    sheet.frames = {};

    sheet.w = w;
    sheet.h = h;
    sheet.xoffset = w / 2;
    sheet.yoffset = h / 2;
    sheet.image_number = num;
    sheet.animation_type = "";
    sheet.image_index = 1;
    sheet.image_speed = 0;

    -- енто не сохраняем в конфиг
    -- sheet.animation_end = 0
   	-- sheet.dir = 1;

   	-- Cut and add 
	for c_y = 0, y do
		for c_x = 0, x do
			if (c_x == x) then break; end
			table.insert(sheet.frames, love.graphics.newQuad(c_x * sheet.w, c_y * sheet.h, sheet.w, sheet.h, width, height));
		end
	end 

	return sheet;
end

------ Анимации ------
animation = {}
animation.loop = function(obj)
	if ( obj.image_index >= obj.image_number + (1 - obj.image_speed) ) then
		obj.image_index = 1;
	end

	obj.image_index = obj.image_index + obj.image_speed;
end

animation.to_end = function(obj)
	if (obj.image_index >= obj.image_number + (1 - obj.image_speed) ) then
		obj.animation_end = true
	else
		obj.image_index = obj.image_index + obj.image_speed;
		obj.animation_end = false
	end
end

animation.ping_pong = function(obj)
	obj.image_index = obj.image_index + obj.image_speed;

	-- To end
	if ( obj.image_index < 1 - obj.image_speed ) then
		obj.image_speed = obj.image_speed * -1;
	end


	-- To start
	if ( obj.image_index > obj.image_number + (1 - obj.image_speed) ) then
		obj.image_speed = obj.image_speed * -1;
	end
end

-- Play Anim
function play_animation(obj)
	animation[obj.animation_type](obj);
end
----------------------
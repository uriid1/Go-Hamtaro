-- Create
local player = object("player_down");

player.speed = 100;

player.dx = 0;
player.dy = 0;

player.old_x = 0;
player.old_y = 0;

player.sector_next = true; -- Если прошел квадрат

--
player.current_move = function() end;

-- Dir Enum
player.current_direction = enum(
	"left",
	"right",
	"up",
	"down",
	"stop"
);
player.dir = player.current_direction.stop;

-- Local's
local ceil  = math.ceil;
local floor = math.floor;

function player:init()
    self.current_move = self.move_in_ground;
    self.dx = 0;
    self.dy = 0;

    self.x = 0;
    self.y = (global.MAP_WIDTH/2) * global.tile_size;
    self.speed = 100;
end

-- Смена анимации
local function change_animation(obj, spr)
    if (obj.sprite_index ~= sprite[spr]) then
        obj.sprite_index = sprite[spr];
        obj.sheet = sheet[spr];
        obj.image_index = 1;
    else
        animation.loop(obj);
    end
end

do  -- Движение по пустому полю
    local self = player;
    -- 
    local key_press_state = {
        [1] = function()
            -- Right
            if key_right then
                if key_up == false and key_down == false then
                    if (self.dir ~= self.current_direction.right) and (self.dir ~= self.current_direction.left) then
                        self.old_x = self.x;
                        self.dir = self.current_direction.right;
                    end
                end
            end
        end;

        [2] = function()
            -- Left
            if key_left then
                if key_up == false and key_down == false then
                    if (self.dir ~= self.current_direction.left) and (self.dir ~= self.current_direction.right) then
                        self.old_x = self.x;
                        self.dir = self.current_direction.left;
                    end
                end
            end
        end;

        [3] = function()
            -- Up
            if key_up then
                if key_left == false and key_right == false then 
                    if (self.dir ~= self.current_direction.up) and (self.dir ~= self.current_direction.down) then
                        self.old_y = self.y;
                        self.dir = self.current_direction.up;
                    end
                end
            end
        end;

        [4] = function()
            -- Down
            if key_down then
                if key_left == false and key_right == false then 
                    if (self.dir ~= self.current_direction.down) and (self.dir ~= self.current_direction.up) then
                        self.old_y = self.y;
                        self.dir = self.current_direction.down;
                    end
                end
            end
        end;
    }

    local kp_algoritm = {1, 2, 3, 4};
    function player.move_in_empty(dt)

        -- Key Pressed ------------
        if self.dx ~= 0 and self.dy == 0 then
            kp_algoritm = {1, 2, 3, 4};
        end

        if self.dy ~= 0 then
            kp_algoritm = {4, 3, 1, 2};
        end

        for i = 1, 4 do
             key_press_state[kp_algoritm[i]]();
        end

        
        ----------------- Acsses Direction --------------
        switch(self.dir, {
            [self.current_direction.right] = function()
                if (self.sector_next == true) then
                    self.dx = 1;
                    self.dy = 0;
                end
            end;

            [self.current_direction.left] = function ()
               if (self.sector_next == true) then
                    self.dx = -1;
                    self.dy = 0;
               end
            end;

            [self.current_direction.up] = function ()
               if (self.sector_next == true) then
                    self.dx = 0;
                    self.dy = -1;
               end
            end;

             [self.current_direction.down] = function ()
                if (self.sector_next == true) then
                    self.dx = 0;
                    self.dy = 1;
                end
            end
        })

        -- To Movement ---------------------------
        -- Left
        if (self.dx == -1) then
            change_animation(self, "player_left");
            --
            self.x = self.x - ceil(self.speed * dt);

             if (self.x % global.tile_size == 0) then
                self.sector_next = true;
                self.old_x = self.x;
            else
                self.sector_next = false;
            end
        end

        -- Right
        if (self.dx == 1) then
            change_animation(self, "player_right");
            --
            self.x = self.x + ceil(self.speed * dt);

            if (self.x % global.tile_size == 0) then
                self.sector_next = true
                self.old_x = self.x;
            else
                self.sector_next = false
            end
        end


        -- Up
        if (self.dy == -1) then
            change_animation(self, "player_up");
            --
            self.y = self.y - ceil(self.speed * dt);

            if (self.y % global.tile_size == 0) then
                self.sector_next = true;
                self.old_y = self.x;
            else
                self.sector_next = false;
            end
        end

        -- Down
        if (self.dy == 1) then
            change_animation(self, "player_down");
            --
            self.y = self.y + ceil(self.speed * dt);

            if (self.y % global.tile_size == 0) then
                self.sector_next = true;
                self.old_y = self.x;
            else
                self.sector_next = false;
            end
        end

        -- Border X Collision
        if (self.x < 0) then
            self.dx = 1;
            self.x = 0;
            self.sector_next = true;
        elseif (self.x > global.CANVAS_WIDTH - global.tile_size) then
            self.dx = -1;
            self.x = global.CANVAS_WIDTH - global.tile_size;
            self.sector_next = true;
        end

        -- Border Y Collision
        if (self.y < 0) then
            self.dy = 1;
            self.y = 0;
            self.sector_next = true;
        elseif (self.y > global.CANVAS_HEIGHT - global.tile_size) then
            self.dy = -1;
            self.y = global.CANVAS_HEIGHT - global.tile_size;
            self.sector_next = true;
        end
    end
end


do -- Движение по закрашенному ( Земле )
    local self = player;
    function player.move_in_ground(dt)
        -- Right
        if key_right then
            if (self.dx == 0) and (self.dy == 0) then
                self.dir = self.current_direction.right;
                self.old_x = self.x;
                self.dx = 1;
            end  
        end
        -- Left
        if key_left then
            if (self.dx == 0) and (self.dy == 0) then
                self.dir = self.current_direction.left;
                self.old_x = self.x;
                self.dx = -1;
            end  
        end
        -- Up
        if key_up then
            if (self.dy == 0) and (self.dx == 0) then
                self.dir = self.current_direction.up;
                self.old_y = self.y;
                self.dy = -1;
            end  
        end
        -- Down
        if key_down then
            if (self.dy == 0) and (self.dx == 0) then
                self.dir = self.current_direction.down;
                self.old_y = self.y;
                self.dy = 1;
            end  
        end
     
        -- Movement  -------------------
        -- Right
        if (self.dx == 1) then
            change_animation(self, "player_right");
            --
            self.x = self.x + ceil(self.speed * dt);

            if (self.x % global.tile_size == 0) then
                self.sector_next = true
                self.old_x = self.x;
                self.dx = 0;
                self.dy = 0;
            else
                self.sector_next = false;
            end
        end

        -- Left
        if (self.dx == -1) then
            change_animation(self, "player_left");
            --
            self.x = self.x - ceil(self.speed * dt);

           if (self.x % global.tile_size == 0) then
                self.sector_next = true;
                self.old_x = self.x;
                self.dx = 0;
                self.dy = 0;
            else
                self.sector_next = false; 
            end
        end

        -- Up
        if (self.dy == -1) then
            change_animation(self, "player_up");
            --
            self.y = self.y - ceil(self.speed * dt);

           if (self.y % global.tile_size == 0) then
                self.sector_next = true;
                self.old_y = self.y;
                self.dy = 0;
                self.dx = 0;
            else
                self.sector_next = false;
            end
        end

        -- Down
        if (self.dy == 1) then
            change_animation(self, "player_down");
            --
            self.y = self.y + ceil(self.speed * dt);

            if (self.y == self.old_y + global.tile_size) then
               self.sector_next = true;
               self.old_y = self.y;
               self.dy = 0;
               self.dx = 0;
            else
                self.sector_next = false;
            end
        end

        -- Border X Collision
        if (self.x < 0) then
            self.dx = 0;
            self.x = 0;
        end
        if (self.x > global.CANVAS_WIDTH - global.tile_size) then
            self.dx = 0;
            self.x = global.CANVAS_WIDTH - global.tile_size;
        end

        -- Border Y Collision
        if (self.y < 0) then
            self.dy = 0;
            self.y = 0;
        end
        if (self.y > global.CANVAS_HEIGHT - global.tile_size)   then
            self.dy = 0;
            self.y = global.CANVAS_HEIGHT - global.tile_size;
        end
    end
end

-- Ну например наступили на своё Говно
function player:damage(y, x)
    if (current_room.grid[y][x] == 2) then
        current_room:clear_2_blocks();
		player:init();
    end
end

key_left = false;
key_right = false;
key_up = false;
key_down = false;

function love.touchmoved(id, x, y, dx, dy)
    key_left  = dx < -5;
    key_right = dx > 5;
    key_up    = dy < -5;
    key_down  = dy > 5;
end

-- Step Event
function player:step(dt)

    if global.os == "pc" then
    	key_left   = love.keyboard.isDown("left");
        key_right  = love.keyboard.isDown("right");
        key_up     = love.keyboard.isDown("up");
        key_down   = love.keyboard.isDown("down");
    end

	--	
	self.current_move(dt)
	--

    if (self.dx == 1) or (self.dy == 1) then
       self:damage(ceil(self.y / global.tile_size), ceil(self.x / global.tile_size))
    elseif (self.dx == -1) or (self.dy == -1) then
       self:damage(floor(self.y / global.tile_size), floor(self.x / global.tile_size));
    end

    if (self.x % global.tile_size == 0) and (self.y % global.tile_size == 0) then
        if (current_room.grid[self.y / global.tile_size][self.x / global.tile_size] == 0) then
            current_room.grid[self.y / global.tile_size][self.x / global.tile_size] = 2;
        end
    end

    -- Закрас и столкновения
    local p_grid = current_room.grid[floor(self.y / global.tile_size)][floor(self.x / global.tile_size)];
    if (p_grid == 1) or (p_grid == 3) then
        --
        if (self.current_move ~= self.move_in_ground) then
            if (self.sector_next == true) then
                self.dx = 0;
                self.dy = 0;
                --
                self.current_move = self.move_in_ground;
            end
        end

        --
        for i = #enemy_instances, 1, -1 do
       		current_room:drop(floor(enemy_instances[i].y / global.tile_size), floor(enemy_instances[i].x / global.tile_size));
   		end

        -- Закрашиваем
        for y = 0, global.MAP_HEIGHT do
            for x = 0, global.MAP_WIDTH do
                if (current_room.grid[y][x] == -1) then
                    current_room.grid[y][x] = 0;
                elseif current_room.grid[y][x] ~= 3 then
                    current_room.grid[y][x] = 1;
                end
            end
        end
    else
        if (self.current_move ~= self.move_in_empty) then
            if (self.sector_next == true) then
                self.current_move = self.move_in_empty;
            end
        end
    end
end

return player
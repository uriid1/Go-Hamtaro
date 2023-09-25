-- Create
local player = object("player_down");

-- Directions
local direction = {
  left  = 0;
  right = 1;
  up    = 2;
  down  = 3;
}
player.direction = direction.down;

-- Animation Enum
local e_anim = {}
e_anim[direction.left]  = "player_left";
e_anim[direction.right] = "player_right";
e_anim[direction.up]    = "player_up";
e_anim[direction.down]  = "player_down";
local anim_dir = e_anim[direction.down];

-- Direction components
local direction_components = {};
direction_components[direction.left]  = {-1, 0};
direction_components[direction.right] = {1, 0};
direction_components[direction.up]    = {0, -1};
direction_components[direction.down]  = {0, 1};

-- States
local states = {
  idle    = 0;
  walking = 1;
}
player.state = states.idle;

player.x_pos = 1;
player.y_pos = 1;
--
player.x_from = player.x_pos;
player.y_from = player.y_pos;
--
player.x_to = player.x_from;
player.y_to = player.y_from;
--
player.ground = false;
player.speed = 100;
player.walk_anim_lenght = 0.075;
player.walk_anim_time = 0;

-- Local's
local ceil  = math.ceil;
local floor = math.floor;

-- Смена анимации
local function change_animation(obj, spr)
  if (obj.sprite_index ~= sprite[spr]) then
    obj.sprite_index = sprite[spr];
    obj.sheet = sheet[spr];
    obj.image_index = 1;
  else
    play_animation(obj);
  end
end

function player:init()
  change_animation(self, e_anim[direction.down]);
  self.direction = direction.down;
  self.state = states.idle;
  --
  self.x_pos = 1;
  self.y_pos = 1;
  --
  self.x = self.x_pos * global.tile_size;
  self.y = self.y_pos * global.tile_size;
  --
  self.x_from = self.x_pos;
  self.y_from = self.y_pos;
  --
  self.x_to = self.x_from;
  self.y_to = self.y_from;

  self.speed = 120;
end

-- Player Move
function player:move(dir)
  local components = direction_components[dir];
  local dx = components[1];
  local dy = components[2];
  local grid = current_room.grid;

  if grid[self.y_pos] then
    self.ground = (grid[self.y_pos][self.x_pos] == 0)
    if (grid[self.y_pos][self.x_pos] == 2) then
      self:damage(self.y_pos, self.x_pos);
    end
  end
  --
  if grid[self.y_pos + dy] then
    local check = grid[self.y_pos + dy][self.x_pos + dx];
    if (check == 0) or (check == 1) or (check == 2) or (check == 3) then
      --
      if self.state == states.idle then
        self.x_from = self.x_pos;
        self.y_from = self.y_pos;
        --
        self.x_to = self.x_pos + dx;
        self.y_to = self.y_pos + dy;
        --
        self.x_pos = self.x_to;
        self.y_pos = self.y_to;
        --
        anim_dir = e_anim[dir];
        self.state = states.walking;
       end
     end
  end 
end

function player:change_move(dir_from, dir_to)
  if (self.ground == true) then
    if (self.direction ~= dir_from) then
      self.direction = dir_to;
    end
  else
    self.direction = dir_to;
    self:move(dir_to);
  end
end

-- Ну например наступили на своё Говно
function player:damage(y, x)
  -- print("Damage");
  sound.damage:play();
  global.lives = global.lives - 1;
  current_room:clear_2_blocks();
  player:init();
end

key_left  = false;
key_right = false;
key_up    = false;
key_down  = false;
function love.touchmoved(id, x, y, dx, dy)
  key_left  = dx < -5;
  key_right = dx > 5;
  key_up    = dy < -5;
  key_down  = dy > 5;
end

-- Step Event
snd_unlock = false
function player:step(dt)
  -- Left
  if (key_left == true) then
    self:change_move(direction.right, direction.left);
  end
  -- Right
  if (key_right == true) then
    self:change_move(direction.left, direction.right);
  end
  -- Up
  if (key_up == true) then
    self:change_move(direction.down, direction.up);
  end
  -- Down
  if (key_down == true) then
    self:change_move(direction.up, direction.down);
  end

  --
  if (self.ground == true) then
    snd_unlock = true;
    self:move(self.direction);
  else
    if (snd_unlock == true) then
      sound.unlock:play();
      snd_unlock = false;
    end
  end

  -- Animation
  if key_up or key_down or key_left or key_right then
    change_animation(self, anim_dir);
  else
    if (self.ground == true) then
      change_animation(self, anim_dir);
    else
      self.image_index = 1;
    end
  end

  -- Walk
  local grid = current_room.grid;
  if (self.state == states.walking) then
    -- Drawing
    if grid[self.y / global.tile_size] then
      if (grid[self.y / global.tile_size][self.x / global.tile_size] == 0) then
        grid[self.y / global.tile_size][self.x / global.tile_size] = 2;
      end
    end

    self.walk_anim_time = self.walk_anim_time + dt;

    local t = self.walk_anim_time / self.walk_anim_lenght;

    if (t >= 1) then
      self.walk_anim_time = 0;
      t = 1;
      self.state = states.idle;
    end

    local _x = lerp(self.x_from, self.x_to, t);
    local _y = lerp(self.y_from, self.y_to, t);

    self.x = _x * global.tile_size;
    self.y = _y * global.tile_size;
  end

  -- Закрас и столкновения
  local p_grid = grid[floor(self.y / global.tile_size)][floor(self.x / global.tile_size)];
  if (p_grid == 1) or (p_grid == 3) then

    --
    for i = #enemy_instances, 1, -1 do
      local enemy = enemy_instances[i]
      if (enemy.type == enemy.types.ghost) then
        current_room:drop(floor(enemy.y / global.tile_size), floor(enemy.x / global.tile_size));
      end
    end

    -- Закрашиваем
    for y = 0, global.MAP_HEIGHT do
      for x = 0, global.MAP_WIDTH do
        if (grid[y][x] == -1) then
          grid[y][x] = 0;
        elseif (grid[y][x] ~= 3) then
          grid[y][x] = 1;
        end
      end
    end
  end
end

return player
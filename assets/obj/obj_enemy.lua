-- Create
local enemy = object:extend();
function enemy:newClass(spr_name, spd)
  enemy.class.newClass(self, spr_name, 0, 0, 0, spd);
  enemy.dx = 0;
  enemy.dy = 0;    
  enemy.types = {
    ghost      = 0;
    monster    = 1;
    fireBall   = 2;
    fireBall_v = 3;
  }
  enemy.type = enemy.types.ghost;

  -- States
  enemy.states = {
    idle    = 0;
    walking = 1;
  }
  enemy.state = enemy.states.idle;

  enemy.x_pos = 0;
  enemy.y_pos = 0;
  --
  enemy.x_from = enemy.x_pos;
  enemy.y_from = enemy.y_pos;
  --
  enemy.x_to = enemy.x_from;
  enemy.y_to = enemy.y_from;
  --
  enemy.walk_anim_lenght = 1 / spd;
  enemy.walk_anim_time = 0;
end

-- Enemy Move
function enemy:move()
  -- Mirror
  if (self.dx ~= 0) then
      self.xscale = self.dx;
    else
      self.xscale = 1;
    end
    if (self.type == self.types.fireBall_v) then
      self.xscale = self.dy;
    end
    -- Animation
    play_animation(self);
    -- Speed
    self.walk_anim_lenght = 1 / self.speed;

    -- p_grid
  local p_grid = current_room.grid;

  if (p_grid[self.y_pos + self.dy][self.x_pos + self.dx] ~= nil) then

    -- Check collision X
    local check_x = p_grid[self.y_pos + self.dy*2][self.x_pos];
    if (check_x == 1) or (check_x == 3) then
      self.dy = -self.dy;
    end
    
    -- Check collision Y
    local check_y = p_grid[self.y_pos + self.dy*2][self.x_pos + self.dx*2];
    if (check_y == 1) or (check_y == 3) then
      self.dx = -self.dx;
    end

    -- All types out ground
    if (self.type == self.types.monster) or
      (self.type == self.types.fireBall) or 
      (self.type == self.types.fireBall_v) then
      if (p_grid[self.y_pos][self.x_pos] == 1) then
        self.destroy = true;
      end 
    end

    -- Player collision
    if (p_grid[self.y_pos + self.dy][self.x_pos + self.dx] == 2) then
      obj.player:damage();
    end
    if (self.y_pos == obj.player.y_pos) and (self.x_pos == obj.player.x_pos) then
      obj.player:damage();
    end

    -- Assess moving
    local check = p_grid[self.y_pos + self.dy][self.x_pos + self.dx];
    if (check == 0) or (check == 2) then
      if (self.state == self.states.idle) then
        self.x_from = self.x_pos;
        self.y_from = self.y_pos;
        --
        self.x_to = self.x_pos + self.dx;
        self.y_to = self.y_pos + self.dy;
        --
        self.x_pos = self.x_to;
        self.y_pos = self.y_to;
        --
        self.state = self.states.walking;
      end
    end
  end 

end

-- Step
local floor = math.floor;
function enemy:step()

  -- Enemy move
  self:move();

  -- 
  if (self.state == self.states.walking) then

    self.walk_anim_time = self.walk_anim_time + dt;

    local t = self.walk_anim_time / self.walk_anim_lenght;

    if (t >= 1) then
      self.walk_anim_time = 0;
      t = 1;
      self.state = self.states.idle;
    end

    local _x = lerp(self.x_from, self.x_to, t);
    local _y = lerp(self.y_from, self.y_to, t);

    self.x = _x * global.tile_size;
    self.y = _y * global.tile_size;
  end
end

return enemy;
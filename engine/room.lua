new_room = class:extend();
new_room.grid = {};
new_room.width     = 60;
new_room.height    = 60;
new_room.tile_size = 12;
new_room.name      = "";

-- Enemy count
new_room.c_ghost       = 0; 
new_room.c_monster     = 0;
new_room.c_fireBall    = 0;
new_room.c_fireBall_v  = 0;
new_room.c_fireBall_hv = 0;

--
local lg = love.graphics;

--
local random = math.random;
local floor = math.floor;
--
local function enemy_ghost_setup(num)
  for i = 1, num or 0 do
    local enemy = {};

    if global.room_index then
      if (global.room_index > 4) then
        enemy = obj.enemy("ghost"..choose(1, 2, 3), choose(5, 7, 9));
      else
        enemy = obj.enemy("ghost1", choose(5, 7, 9));
      end
    else
      enemy = obj.enemy("ghost1", choose(5, 7, 9));
    end

    enemy.type = enemy.types.ghost;
    enemy.x = random(4 * global.tile_size, 56 * global.tile_size);
    enemy.y = random(4 * global.tile_size, 56 * global.tile_size);
    enemy.x_pos = floor(enemy.x / global.tile_size);
    enemy.y_pos = floor(enemy.y / global.tile_size);
    enemy.dx = choose(1, -1);
    enemy.dy = choose(1, -1);
    table.insert(enemy_instances, enemy);
  end
end

local function enemy_monster_setup(num)
  for i = 1, num or 0 do
    local enemy = obj.enemy("monster_g"..math.random(8), choose(5, 7, 9));
    enemy.type = enemy.types.monster;
    enemy.x = random(4 * global.tile_size, 56 * global.tile_size);
    enemy.y = random(4 * global.tile_size, 56 * global.tile_size);
    enemy.x_pos = floor(enemy.x / global.tile_size);
    enemy.y_pos = floor(enemy.y / global.tile_size);
    enemy.dx = choose(1, -1);
    enemy.dy = choose(1, -1);
    table.insert(enemy_instances, enemy);
  end
end

local function enemy_fireball_setup(num)
  for i = 1, num or 0 do
    local enemy = obj.enemy("fire_ball", choose(12, 15));
    enemy.type = enemy.types.fireBall;
    enemy.x = random(4 * global.tile_size, 56 * global.tile_size);
    enemy.y = random(4 * global.tile_size, 56 * global.tile_size);
    enemy.x_pos = floor(enemy.x / global.tile_size);
    enemy.y_pos = floor(enemy.y / global.tile_size);
    enemy.dx = choose(1, -1);
    enemy.dy = 0;
    table.insert(enemy_instances, enemy);
  end
end

local function enemy_fireball_v_setup(num)
  for i = 1, num or 0 do
    local enemy = obj.enemy("fire_ball_v", choose(12, 15));
    enemy.image_angle = 270;
    enemy.type = enemy.types.fireBall_v;
    enemy.x = random(4 * global.tile_size, 56 * global.tile_size);
    enemy.y = random(4 * global.tile_size, 56 * global.tile_size);
    enemy.x_pos = floor(enemy.x / global.tile_size);
    enemy.y_pos = floor(enemy.y / global.tile_size);
    enemy.dx = 0;
    enemy.dy = choose(1, -1);
    table.insert(enemy_instances, enemy);
  end
end

local function enemy_fireball_hv_setup(num)
  for i = 1, num or 0 do
    local enemy = {};
    enemy = obj.enemy("fire_ball_v", choose(9, 12, 14));
    enemy.type = enemy.types.ghost;
    enemy.x = random(4 * global.tile_size, 56 * global.tile_size);
    enemy.y = random(4 * global.tile_size, 56 * global.tile_size);
    enemy.x_pos = floor(enemy.x / global.tile_size);
    enemy.y_pos = floor(enemy.y / global.tile_size);
    enemy.dx = choose(1, -1);
    enemy.dy = choose(1, -1);
    table.insert(enemy_instances, enemy);
  end
end

function new_room:init(init)
  if init then
    -- Play Music
    if (music.walk:isPlaying() == false) then
      music.walk:setLooping(true):play();
    else
      if (music.walk:isPaused() == true) then
        music.walk:resume();
      end
    end
  end

  -- Global const
  global.MAP_WIDTH  = self.width;
  global.MAP_HEIGHT = self.height;
  global.MAP_ALPHA = 1;

  -- Canvas
  global.tile_size      = self.tile_size;
  global.CANVAS_WIDTH   = global.MAP_WIDTH  * global.tile_size;
  global.CANVAS_HEIGHT  = global.MAP_HEIGHT * global.tile_size;
  global.CANVAS_XOFFSET = global.CANVAS_WIDTH / 2;
  global.CANVAS_YOFFSET = global.CANVAS_HEIGHT / 2;

  -- Game
  global.room_index = self.index;
  global.header_y = 90;
  global.score = 0;
  global.stage_clear = true;
  global.map_update  = true;
  global.map_draw    = true;
  global.map_empty = 0;

  -- global.game_over   = false;
  if (global.game_over == true) then
    global.lives = 3;
    global.game_over = false;
  end

  -- Map
  global.map_fill = 0;
  for y = 0, self.height do
    self.grid[y] = {};
    for x = 0, self.width do
      --
      self.grid[y][x] = 0;
      --
      if (y == 0) or (x == 0) or (y == self.height) or (x == self.width)         or
         (y == 1) or (x == 1) or (y == self.height - 1) or (x == self.width - 1) or
         (y == 1) or (x == 1) or (y == self.height - 2) or (x == self.width - 2)
      then
        self.grid[y][x] = 3;
      end

      if self.grid[y][x] == 0 then
        global.map_fill = global.map_fill + 1;
      end
    end
  end

  math.randomseed(os.clock());

  -- Enemy delete
  if (#enemy_instances > 0) then
    for i = #enemy_instances, 1, -1 do
      instance_destroy(enemy_instances, i);
    end
  end

  -- Create enemy
  enemy_ghost_setup(self.c_ghost, self.index);
  enemy_monster_setup(self.c_monster);
  enemy_fireball_setup(self.c_fireBall);
  enemy_fireball_v_setup(self.c_fireBall_v);
  enemy_fireball_hv_setup(self.c_fireBall_hv);

  -- Player
  obj.player:init();
  obj.player.xoffset = (obj.player.w/2) - global.tile_size * 0.5;
  obj.player.yoffset = (obj.player.h/2) - global.tile_size * 0.5;

  -- Save game
  game_save();
end

function new_room:update(dt)
end

-- Clear Stage -----------------------------
local sc_size   = 0;
local sc_rotate = 0;
local sc_alpha  = 1;
local sc_timer  = 0;
local sc_activate = false;
local sc_start = false;
function stage_clear(room_next, state)
  --
  if (state == false) then
    sc_size   = 0;
    sc_rotate = 0;
    sc_alpha  = 1;
    sc_timer  = 0;
    sc_activate = false;
    sc_start = false;
    return;
  else
    -- music.walk:pause();

    if (sc_start == false) then
      if (sound.complate:isPlaying() == false) then
        sound.complate:play();
      end
      sc_start = true;
    end
  end

  global.map_update = false;
  sc_size   = lerp(sc_size, 100, 5*dt);
  sc_rotate = lerp(sc_rotate, 360, 5*dt);
  sc_timer  = sc_timer + dt;

  if (sc_timer >= 3) then
    sc_alpha = lerp(sc_alpha, 0, 5*dt);
    global.MAP_ALPHA = lerp(global.MAP_ALPHA, 0, 5*dt);

    if (global.MAP_ALPHA <= 5*dt) then
      lg.setFont(font.large);
      local text = "Enter/Space to continue";
      obj.hamtaro_win.y = global.CANVAS_HEIGHT;
      obj.hamtaro_win.x = (global.CANVAS_XOFFSET - font.large:getWidth(text)/2) - obj.hamtaro_win.xoffset;
      obj.hamtaro_win:draw_self();
      lg.setColor(hex("18313fff"));
      lg.print(text, global.CANVAS_XOFFSET - 3, global.CANVAS_HEIGHT + 3, 0, 1, 1, font.large:getWidth(text)/2, font.large:getHeight(text)/2)
      lg.setColor(1, 1, 1, 1);
      lg.print(text, global.CANVAS_XOFFSET, global.CANVAS_HEIGHT, 0, 1, 1, font.large:getWidth(text)/2, font.large:getHeight(text)/2)

      if (key_activate == true) then
        if sc_activate == false then
          sound.menu_confirm:play();
          
          -- Next level
          obj.transition:room_goto(room_next);
          sc_activate = true;
        end
      end
    end
  end

  lg.setColor(1, 1, 1, sc_alpha);
  lg.draw(sprite.stage_clear, (global.CANVAS_XOFFSET), (global.CANVAS_YOFFSET) + global.header_y, math.rad(sc_rotate), sc_size/100, sc_size/100, sprite.stage_clear:getWidth()*0.5, sprite.stage_clear:getHeight()*0.5);
end
---------------------------------------------

-- Game Over --------------------------------
local
ham_w,
ham_h,
ham_xoffset,
ham_yoffset,
continue_w,
continue_h, 
continue_xoffset,
continue_yoffset,
go_xoffset,
go_yoffset;

local hsw        = 1;
local hsh        = 1;
local go_x       = -200;
local over_index = 2;

local gm_start = false;
local gm_close = false;
local gm_init  = false;
local game_over_init = function()
  ham_w = sprite.hamtaro_cry:getWidth();
  ham_h = sprite.hamtaro_cry:getHeight();
  ham_xoffset = ham_w / 2;
  ham_yoffset = ham_h / 2;

  hsw = 1;
  hsh = 1;

  -- Hamtaro
  if (ham_h > global.CANVAS_HEIGHT) then
    hsh = (global.CANVAS_HEIGHT / ham_h) - 0.2;
    hsw = hsh;
  else 
    hsh, hsw = 1, 1;
  end

  -- Continue
  continue_w = sprite.continue:getWidth();
  continue_h = sprite.continue:getHeight();
  continue_xoffset = continue_w / 2;
  continue_yoffset = continue_h / 2;

  -- Spr Game Over
  go_x = -200;
  go_xoffset = sprite.game_over:getWidth() / 2;
  go_yoffset = sprite.game_over:getHeight() / 2;

  over_index = 2;
end

function game_over(self, state)
  --
  if (state == false) then
    go_x = -200;
    over_index = 2;
    gm_start = false;
    if (gm_init == false) then
      game_over_init();
      gm_init = true;
    end
    return;
  else
    if (gm_start == false) then
      gm_start = true;
      gm_close = false;

      music.walk:pause();
      sound.over:play();
    end
  end

  -- key
  if key_left then
    if (over_index ~= 2) and not key_right then
      sound.menu_move:play();
      over_index = 2;
    end
  end

  if key_right then
    if (over_index ~= 1) and not key_left then
      sound.menu_move:play();
      over_index = 1;
    end
  end

  -- Transition
  if (key_activate) then

    if (gm_close == false) then
      sound.menu_confirm:play();
      sound.over:stop();
      gm_close = true;
    end
    
    -- Restart level
    if (over_index == 2) then
      obj.transition.room_state = "restart";
      obj.transition.state = "fade_in";
      obj.transition.label = self.name;
      obj.transition.activate = true;
    end
    --
    if (over_index == 1) then
      obj.transition:room_goto(1);
    end
  end

  global.map_update = false;
  global.map_draw = false;

  lg.setColor(1, 1, 1, 1);
  go_x = lerp(go_x, go_yoffset + 50, 5*dt);

  lg.draw(sprite.hamtaro_cry, global.CANVAS_XOFFSET, global.CANVAS_YOFFSET + global.header_y, 0, hsw, hsh, ham_xoffset, ham_yoffset);
  lg.draw(sprite.game_over,   global.CANVAS_XOFFSET, go_x, 0, 1, 1, go_xoffset, go_yoffset);

  -- Spr Continue
  local pos_x = (continue_xoffset + continue_xoffset + 210) / 2;
  lg.draw(sprite.continue, pos_x, (global.CANVAS_HEIGHT + global.header_y - 30) - continue_yoffset, 0, 1, 1, continue_xoffset, continue_yoffset);
  
  -- Yes
  local yes_index = (over_index == 1) and 1 or 2;
  lg.draw(sprite.yes, sheet.yes.frames[yes_index], pos_x + continue_xoffset + 90, (global.CANVAS_HEIGHT + global.header_y - 30) - sheet.yes.yoffset, 0, 1, 1, sheet.yes.xoffset, sheet.yes.yoffset);
  
  -- No
  local no_index = (over_index == 1) and 2 or 1;
  lg.draw(sprite.no, sheet.no.frames[no_index], pos_x + continue_xoffset + 210, (global.CANVAS_HEIGHT + global.header_y - 30) - sheet.no.yoffset, 0, 1, 1, sheet.no.xoffset, sheet.no.yoffset);
end
-------------------------------------------

-- Отчиска того что рожал игрок
function new_room:clear_2_blocks()
  for y = 0, self.height do
    for x = 0, self.width do
      if (self.grid[y][x] == 2) then
        self.grid[y][x] = 0;
      end
    end
  end
end

-- Draw empty blocks
-- 1 - is empty
-- 0 - is ground
function new_room:drop(y, x)
  if (self.grid[y][x] == 0) then
    self.grid[y][x] = -1;
  end

  if (self.grid[y - 1][x] == 0) then
    self:drop(y - 1, x);
  end
  if (self.grid[y + 1][x] == 0) then
    self:drop(y + 1, x);
  end
  if (self.grid[y][x - 1] == 0) then
    self:drop(y, x - 1);
  end
  if (self.grid[y][x + 1] == 0) then
    self:drop(y, x + 1);
  end
end

-- Grid draw in texture
local d_grid = lg.newCanvas(new_room.width * new_room.tile_size, new_room.height * new_room.tile_size);
lg.setCanvas(d_grid)
  lg.clear();
  -- Grid
  lg.setColor(1, 1, 1, 0.1);
    for y = 0, new_room.height - 1 do
        for x = 0, new_room.width - 1 do
          lg.rectangle("line", x*new_room.tile_size, y*new_room.tile_size, new_room.tile_size, new_room.tile_size)
        end
    end
lg.setCanvas();

function new_room:draw()

  -- Debug
  if (global.debug == true) then
    -- Grid
    lg.draw(d_grid);

    -- Rect
    lg.setColor(0, 0, 0, .5);
    lg.rectangle("fill", 5, 0, 100, 100);

    lg.setColor(1, 1, 1, 1);
    lg.setFont(font.small);
    lg.print("FPS: " .. love.timer.getFPS(), 10, 5);


    lg.print("DIR: " .. obj.player.direction, 10, 30);
    if (obj.player.ground) then
      lg.print("IN GROUND", 10, 55);
    else
      lg.print("IN EMPTY", 10, 55);
    end
  end
end

function new_room:draw_map()
  local empty = 0;
  
  shader.rainbow:send('currentTime', os.clock() * 10);
  lg.setShader(shader.rainbow)
  for y = 0, self.height do
    for x = 0, self.width do
      -- Empty
      if (self.grid[y][x] == 1) then
        empty = empty + 1;
      end

      -- Player blocks
      if (self.grid[y][x] == 2) then
        lg.rectangle("fill", x * global.tile_size, y * global.tile_size, global.tile_size, global.tile_size);
        goto continue;
      end

      ::continue::
    end
  end
  lg.setShader()
  global.map_empty = empty;
end

return new_room;
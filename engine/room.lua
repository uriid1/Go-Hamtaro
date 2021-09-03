new_room = class:extend();
new_room.grid = {};
new_room.width = 60;
new_room.height = 60;
new_room.tile_size = 12;

function new_room:init()
  -- To global
  global.MAP_WIDTH  = room_game.width;
  global.MAP_HEIGHT = room_game.height;
  global.MAP_ALPHA = 1;
  -- Canvas
  global.tile_size     = room_game.tile_size;
  global.CANVAS_WIDTH  = global.MAP_WIDTH  * global.tile_size;
  global.CANVAS_HEIGHT = global.MAP_HEIGHT * global.tile_size;
  -- Game
  global.score = 0;
  global.live = 3;
  global.stage_clear = true;
  global.game_over = false;

  -- Map
  global.map_fill = 0;
  for y = 0, self.height do
      self.grid[y] = {};
      for x = 0, self.width do
          --
            self.grid[y][x] = 0;
            --
            if (y == 0) or (x == 0) or (y == self.height) or (x == self.width ) or 
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
end

-- Отчиска
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
-- 0 - is empty code
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

function new_room:update() end
function new_room:draw() end

--
global.map_empty = 0;
--
local lg = love.graphics;
function new_room:draw_map()  
  -- Draw walls
  local tile_size = self.tile_size;
  local empty = 0;
  for y = 0, self.height do
      for x = 0, self.width do

          local mult_x = x * tile_size;
          local mult_y = y * tile_size;

          -- Empty
          if (self.grid[y][x] == 1) then
              empty = empty + 1;
              goto continue;
          end

          -- And empty
          if (self.grid[y][x] == 0) then
              lg.setColor(0, 0, 0.5, global.MAP_ALPHA);
              lg.rectangle("fill", mult_x, mult_y, tile_size, tile_size);
              goto continue;
          end

          -- Рисуем то что рожает игрок
          if (self.grid[y][x] == 2) then
              lg.setColor(1, 1, 1, global.MAP_ALPHA);
              lg.rectangle("fill", mult_x, mult_y, tile_size, tile_size);
              goto continue;
          end

          -- Blocks
          if (self.grid[y][x] == 3) then
              lg.setColor(0.1, 0.1, 0.1, 0);
              lg.rectangle("fill", mult_x, mult_y, tile_size, tile_size);
              goto continue;
          end

          ::continue::
      end
  end
  global.map_empty = empty;
end
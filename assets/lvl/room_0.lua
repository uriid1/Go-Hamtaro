-- Это костыль для решения проблемы с почетом высоты устройств.
room_loading = {};

-- Load res
local lg = love.graphics;
local spr_micro = lg.newImage("assets/spr/spr_loading.png");
spr_micro:setFilter('nearest', 'nearest');

-- Debug resolution
local i = 0;
local debug_lvl = false;

-- Loading resource
require("resource");

local next = false;
function room_loading:update()
  --
  if global.fps >= math.floor(1.0 / love.timer.getDelta()) - 2 then
    debug_lvl = true; 
  end

  if (debug_lvl == true) then
    -- goto next room
    if (next == false) then
      obj.transition:room_goto(1);
      next = true;
    end
  end
end

local fnt_small = lg.newFont('assets/fnt/game.otf', 30);
lg.setFont(fnt_small);
local loading = "Loading";
local dot_time = 0;
local dot_count = 0;

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

local x = global.win_xoffset - mw * 0.5;
local y = global.win_yoffset - mh * 0.5;
--
local ly = global.win_h - 50;
--
local ry = global.win_h - 61;
function room_loading:draw()
  lg.setBackgroundColor(hex("3c84b5ff"));
  -- Parse screen resolution
  global.win_w = lg.getWidth();
  global.win_h = lg.getHeight();
  global.win_xoffset = global.win_w * 0.5;
  global.win_yoffset = global.win_h * 0.5;


  lg.setColor(1, 1, 1, 1);
  lg.draw(spr_micro, x, y, 0, sx, sy);
  
  lg.setColor(0, 0, 0, 0.5);  
  lg.rectangle("fill", 17, ry, fnt_small:getWidth(loading) + 17, 58)

  dot_time = (dot_time + 0.5) % 10;
  if (dot_time >= 9.5) then
    loading = loading .. ".";
    dot_count = dot_count + 1;
  end

  if (dot_count == 4) then
    loading = "Loading";
    dot_count = 0;
  end

  lg.setColor(1, 1, 1, 1);
  lg.print(loading, 25, ly);
end
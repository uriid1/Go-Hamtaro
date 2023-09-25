--
local room = {};

function room:init()
  sound.win:play();
end

-- Setup
room.name = "You Win!";

-- local's
local lg = love.graphics;

-- Update Game
function room:update(dt) end

--
local angle_cirlce = 0;
--
local ham_xoffset = sprite.hamtaro_win:getWidth() / 2;
local ham_yoffset = sprite.hamtaro_win:getHeight() / 2;

-- Logo
local logo_angle   = 0;
local logo_sin     = 0;
local logo_w       = sprite.all_clear:getWidth();
local logo_h       = sprite.all_clear:getHeight();
local logo_xoffset = logo_w / 2;
local logo_yoffset = logo_h / 2;

function room:draw()
  lg.setColor(1, 1, 1, 1);

  -- Color circle
  angle_cirlce = (angle_cirlce + 10*dt)%360;
  lg.draw(sprite.color_circle, global.CANVAS_XOFFSET, global.CANVAS_YOFFSET + 90, math.rad(angle_cirlce), 10, 10, 64, 64);

  -- Ham
  lg.draw(sprite.hamtaro_win, global.CANVAS_XOFFSET, global.CANVAS_YOFFSET + 90, 0, 1, 1, ham_xoffset, ham_yoffset);

  -- Logo
  logo_sin = logo_sin + ((math.pi*2) / 180);
  logo_angle = math.sin(logo_sin);
  lg.draw(sprite.all_clear, global.CANVAS_XOFFSET, 150, math.rad(logo_angle), 1, 1, logo_xoffset, logo_yoffset);

  -- Thx
  lg.setFont(font.large);
  lg.setColor(hex("18313fff"));
  local text = "Thank you for playing \nthe demo version of the game!";
  lg.print(text, global.CANVAS_XOFFSET, global.CANVAS_HEIGHT, 0, 1, 1, font.large:getWidth(text)/2, font.large:getHeight(text)/2)
  lg.setColor(1, 1, 1, 1);
  lg.print(text, global.CANVAS_XOFFSET + 3, global.CANVAS_HEIGHT - 3, 0, 1, 1, font.large:getWidth(text)/2, font.large:getHeight(text)/2)
end

function room:keypressed(key)
  if (key == "return") then
    if (obj.transition.activate == false) then
      obj.transition:room_goto(1);
    end
  end
end

return room
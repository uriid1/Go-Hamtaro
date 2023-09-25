--
local room_menu = {};
room_menu.name = "Menu";

-- Menu
local menu = {}
menu[1] = "New Game";
menu[2] = "Continue";
menu[3] = "Web Page";
menu[4] = "Exit";
local menu_index = 1;

local saves;
function room_menu:init()
  music.happy:setLooping(true):play();
  music.walk:stop();

  menu_index = 1;
  -- If saves exists
  saves = check_save();
  if saves then
    load_save();
    menu[1] = "Continue";
    menu[2] = "New Game";
  else
    global.room_index = 2;
  end
end

-- Setup
local lg = love.graphics; 

function room_menu:update(dt)
end

-- Ham
local hamtaro_w = sprite.hamtaro_menu:getWidth();
local hamtaro_h = sprite.hamtaro_menu:getHeight();
local hamtaro_xoffset = hamtaro_w / 2;
local hamtaro_yoffset = hamtaro_h / 2;

-- Color circle
local angle_cirlce = 0;

-- Logo
local logo_angle = 0;
local logo_sin = 0;
local logo_w = sprite.logo:getWidth();
local logo_h = sprite.logo:getHeight();
local logo_xoffset = logo_w / 2;
local logo_yoffset = logo_h / 2;

function room_menu:draw()
  -- bg color
  lg.setBackgroundColor(hex("7265adff"));

  -- ham sit
  lg.setColor(1, 1, 1, 1);
  local x = global.CANVAS_WIDTH - (hamtaro_xoffset + 25);
  local y = global.CANVAS_HEIGHT - (hamtaro_yoffset - 70);

  -- Color circle
  angle_cirlce = (angle_cirlce + 10*dt)%360;
  lg.draw(sprite.color_circle, x, y, math.rad(angle_cirlce), 10, 10, 64, 64);
  lg.draw(sprite.hamtaro_menu, x, y, 0, 1, 1, hamtaro_xoffset, hamtaro_yoffset);

  -- Logo
  logo_sin = logo_sin + ((math.pi*2) / 180);
  logo_angle = math.sin(logo_sin);
  lg.draw(sprite.logo, global.CANVAS_XOFFSET, 150, math.rad(logo_angle), 1, 1, logo_xoffset, logo_yoffset);

  -- Menu 
  lg.setFont(font.menu);
  for i = 1, 4 do
    -- Shadow
    lg.setColor(hex("18313fff"));
    lg.print(menu[i], 17, global.CANVAS_YOFFSET + (53 + 70*i));

    -- Text
    lg.setColor(1, 1, 1, 1);
    if (menu_index == i) then
      lg.setColor(hex("ff7f5dff"));
    end
    lg.print(menu[i], 20, global.CANVAS_YOFFSET + (50 + 70*i));
  end
end

function room_menu:keypressed(key)
  if (key == "down") then
    menu_index = menu_index + 1;
    if (menu_index < 5) then
      sound.menu_move:play();
    end
  end

  if (key == "up") then
    menu_index = menu_index - 1;
    if (menu_index > 0) then
      sound.menu_move:play();
    end
  end

  if (key == "return") then
    if (obj.transition.activate == false) then
      if (menu_index ~= -1) then
        sound.menu_confirm:play();
        music.happy:stop();
      end

      -- New Game
      if (menu[menu_index] == "New Game") then
        global.lives = 3;
        obj.transition:room_goto(2);
        menu_index = -1;
      end

      -- Continue
      if (menu[menu_index] == "Continue") then
        if (global.room_index ~= 2) then
          obj.transition:room_goto(global.room_index);
        else
          obj.transition:room_goto(2);
        end
        menu_index = -1;
      end

      -- Open Site
      if (menu[menu_index] == "Web Page") then
        love.system.openURL("https://microvolnovka.itch.io/go-hamtaro");
      end

      -- Exit
      if (menu[menu_index] == "Exit") then
        love.event.quit();
      end
    end
  end

  if (menu_index ~= -1) then
    menu_index = clamp(menu_index, 1, 4);
  end
end

return room_menu
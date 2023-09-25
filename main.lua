io.stdout:setvbuf("no");

function love.load()
  ------------  LIBS  ------------
  simple_scale = require "libs.simpleScale";
  if simple_scale then
    local sw = 720;
    local sh = 810;
    simpleScale.setWindow(sw, sh, sw, sh, {fullscreen = false, resizable = true});
  end
  love.graphics.setDefaultFilter("nearest", "nearest");
  --
  serialize = require "libs.serialize";
  audio     = require "libs.wave";
  class     = require "libs.class";

  ------------ ENGINE ------------
  require "engine.object";
  require "engine.engine";
  require "engine.collision";
  require "engine.sheet";
  require "engine.room";
  require "engine.easing";

  -- Delta time
  dt = 1 / 30;
  
  -- For Mobile's
  if (love.system.getOS() == "Android" or love.system.getOS() == "Ios") then
    global.os = "mobile";
    love.window.setFullscreen(true); -- Fix
  else
    global.os = "pc";
    love.window.setIcon(love.image.newImageData( "icon.png" ));
  end

  -- Load room loading
  require("assets/lvl/room_0");

  -- Current room
  current_room = room_loading;
end

--- Debug
-- local res = "";
-- local old_time = os.time()
-- function love.textinput(text)
--  time = os.time();
--  if (time - old_time > 5) then
--    res = "";
--    old_time = time;
--  end
--  if (#res > 50) then
--    res = "";
--  end
--  res = res .. text;

--  -- On/off debug
--  if string.find(res, "debug") then
--    global.debug = not global.debug
--    res = "";
--  end

--  -- Kill player
--  if string.find(res, "kill") then
--    global.lives = -1;
--    res = ""
--  end

--  -- Clear Stage
--  if string.find(res, "clear") then
--    if enemy_instances then
--      for i = #enemy_instances, 1, -1 do
--        table.remove(enemy_instances, i);
--      end
--      res = ""
--    end
--  end
-- end


function love.keypressed(key)
  if current_room.keypressed then
    current_room:keypressed(key);
  end
end

function love.update()
  -- Mouse position
  mouse_x, mouse_y = love.mouse.getPosition();
  -- keys
    if (global.os == "pc") then
    key_left     = love.keyboard.isDown("left")   or love.keyboard.isDown("a");
    key_right    = love.keyboard.isDown("right")  or love.keyboard.isDown("d");
    key_up       = love.keyboard.isDown("up")     or love.keyboard.isDown("w");
    key_down     = love.keyboard.isDown("down")   or love.keyboard.isDown("s");
    key_activate = love.keyboard.isDown("return") or love.keyboard.isDown("space");
    end

  -- dt
  global.fps = love.timer.getFPS();
  dt = 1 / global.fps;

  -- Current room update
  current_room:update(dt);
  
  -- Libs update
  -- Scale
  if simple_scale then
    simple_scale.resizeUpdate();
  end
end

function love.draw()
  -- Game
  if simple_scale then simple_scale.set(); end
  if (current_room == room_loading) then
    current_room:draw();
  else
    -- Game Draw
      current_room:draw();
    love.graphics.setColor(1, 1, 1, 1);
  end
  -- Transition
  if obj.transition then
    obj.transition:draw_self();
  end
  if simple_scale then  simple_scale.unSet(); end
end
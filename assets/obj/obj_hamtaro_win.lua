-- Create
local hamtaro_win = object("hamtaro_win1");

function hamtaro_win:draw_self()
    object.draw_self(self);
    play_animation(self);
end

return hamtaro_win
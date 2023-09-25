local transition = {};

transition.state = "fade_in";
transition.activate = false;
transition.label = "PUBG";
transition.room_state = "restart";
transition.room_next = transition;

local tr1_y = 0;    -- transiton rectangle top
local tr2_y;        -- transiton rectangle down
local timer = 0;    -- fictive timer
--
local lg = love.graphics; 
function transition:draw_self()
    if (self.activate == true) then
        -- Debug
        if (tr2_y == nil) then
            tr2_y = global.CANVAS_HEIGHT + global.header_y;
        end
        -- Fade In
        if (self.state == "fade_in") then
            local text = tr1_y >= global.CANVAS_YOFFSET - 40;
            -- White Rect
            if (text) then 
                lg.setColor(1, 1, 1, 1);
                lg.rectangle("fill", 0, 0, global.CANVAS_WIDTH, global.CANVAS_HEIGHT);
            end

            lg.setColor(0, 0, 0, 1);
            -- Top rect
            tr1_y = lerp(tr1_y, global.CANVAS_YOFFSET + global.header_y/2 + 4, 5*dt);
            lg.rectangle("fill", 0, 0, global.CANVAS_WIDTH, tr1_y);
            -- Down rect
            tr2_y = lerp(tr2_y, global.CANVAS_YOFFSET + global.header_y/2 - 4, 5*dt);
            lg.rectangle("fill", 0, tr2_y, global.CANVAS_WIDTH, global.CANVAS_HEIGHT);

            -- Text
            if (text) then
                lg.setColor(1, 1, 1, 1);
                lg.setFont(font.game);
                lg.print(self.label, global.CANVAS_XOFFSET, global.CANVAS_YOFFSET + global.header_y/2, 0, 1, 1, font.game:getWidth(self.label)/2, font.game:getHeight(self.label)/2);
            end

            -- Room init
            if (math.ceil(tr1_y) >= (global.CANVAS_YOFFSET + global.header_y/2)) then
                timer = timer + dt;
                -- Restart
                if (self.room_state == "restart") then
                    current_room:init(true);
                    self.room_state = "";
                end
                -- Next room
                if (self.room_state == "room_next") then
                    room_goto(self.room_next);
                    self.room_state = "";
                end
                if (timer >= 1) then
                    self.state = "fade_out";
                    timer = 0;
                end
            end
        end

        -- Fade out
        if (self.state == "fade_out") then
            lg.setColor(0, 0, 0, 1);
            -- Top rect
            tr1_y = lerp(tr1_y, 0, 8*dt);
            lg.rectangle("fill", 0, 0, global.CANVAS_WIDTH, tr1_y);
            -- Down rect
            tr2_y = lerp(tr2_y, global.CANVAS_HEIGHT + global.header_y, 8*dt);
            lg.rectangle("fill", 0, tr2_y, global.CANVAS_WIDTH, global.CANVAS_HEIGHT);

            if (tr2_y >= (global.CANVAS_HEIGHT + global.header_y) - 5) then
                self.activate = false;
            end
        end

    end
end

function transition:room_goto(room_index)
    self.room_state = "room_next";
    self.state = "fade_in";
    self.room_next = room[room_index];
    self.label = room[room_index].name;
    self.activate = true;
end

return transition;
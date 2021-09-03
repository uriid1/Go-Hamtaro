-- Create
local enemy = object:extend();
function enemy:newClass(spr_name, x, y)
	enemy.class.newClass(self, spr_name, x, y);
	enemy.dx = 0;
	enemy.dy = 0;
	enemy.rotate = 0;
end

-- Step
local floor = math.floor;
function enemy:step(dt)
    -- Mirror
    self.xscale = self.dx;
    animation.loop(self);
    
    -- Left & Right
    self.x = self.x + self.dx;
    local my = floor( (self.y + self.dy*8) / global.tile_size );
    local mx = floor( (self.x + self.dx*8) / global.tile_size );
    
    if (current_room.grid[my][mx] == 1) or (current_room.grid[my][mx] == 3) then
        self.dx = -self.dx;
        self.x = self.x + self.dx;
    end
    
    -- Top & Down
    self.y = self.y + self.dy;
    local my = floor( (self.y + self.dy*8) / global.tile_size );
    local mx = floor( (self.x + self.dx*8) / global.tile_size );

    if (current_room.grid[my][mx] == 1) or (current_room.grid[my][mx] == 3) then
        self.dy = -self.dy;
        self.y = self.y + self.dy;
    end

    -- Player collision
    if (current_room.grid[my][mx] == 2) then
        --obj.player:damage(my, mx);
    end

end

return enemy;
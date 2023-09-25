function collision(box1, box2, hsp, vsp)
     if (box1.mask_type == "rect" or box1.mask_type == "self") and
        (box2.mask_type == "rect" or box2.mask_type == "self") then
        return collision_map.box_box(box1, box2, hsp, vsp);
    end
end

collision_map = {};
collision_map.box_box = function( box1, box2, hsp, vsp )
    local mx1, my1, mxoff1, myoff1
    local mx2, my2, mxoff2, myoff2

    if (box1.mask_type == "rect") then
        mx1 = box1.mask.x
        my1 = box1.mask.y
        mxoff1 = box1.mask.xoffset
        myoff1 = box1.mask.yoffset
    elseif (box1.mask_type == "self") then
        mx1 = 0
        my1 = 0
        mxoff1 = box1.xoffset
        myoff1 = box1.yoffset
    end

    if (box2.mask_type == "rect") then
        mx2 = box2.mask.x
        my2 = box2.mask.y
        mxoff2 = box2.mask.xoffset
        myoff2 = box2.mask.yoffset
    elseif (box2.mask_type == "self") then
        mx2 = 0
        my2 = 0
        mxoff2 = box2.xoffset
        myoff2 = box2.yoffset
    end

    return ( ( box1.x + mx1 ) - mxoff1 ) + hsp < ( box2.x + mx2 ) + mxoff2 and
           ( ( box1.x + mx1 ) + mxoff1 ) + hsp > ( box2.x + mx2 ) - mxoff2 and
           ( ( box1.y + my1 ) - myoff1 ) + vsp < ( box2.y + my2 ) + myoff2 and
           ( ( box1.y + my1 ) + myoff1 ) + vsp > ( box2.y + my2 ) - myoff2

end

-- Collsion AABB <-> AABB
function collision_aabb(x1, y1, x2, y2, xoffset1, yoffset1, xoffset2, yoffset2)
    return (x1 - xoffset1 < x2 + xoffset2) and
           (x1 + xoffset1 > x2 - xoffset2) and
           (y1 - yoffset1 < y2 + yoffset2) and
           (y1 + yoffset1 > y2 - yoffset2)
end

-- Collision BOX <-> POINT ratated
function collision_angle_box(px, py, r_x, r_y, r_ox, r_oy, r_w, r_h, r_angle)
    local cos_angle = math.cos(-r_angle)
    local sin_angle = math.sin(-r_angle)
    local diff_px = px - r_x
    local diff_py = py - r_y
    return cos_angle * diff_px - sin_angle * diff_py >= -r_ox        and
           cos_angle * diff_px - sin_angle * diff_py <= r_w - r_ox   and
           sin_angle * diff_px + cos_angle * diff_py >= -r_oy        and
           sin_angle * diff_px + cos_angle * diff_py <= r_h - r_oy
end

-- Collision CIRCLE <-> BOX (vsp & hsp)
function collision_circle_rect(_circle, _rect, hsp, vsp)
    local DeltaX = _circle.x - math.max( (_rect.x - _rect.xoffset*_rect.xscale) - hsp, math.min(_circle.x, (_rect.x + _rect.xoffset*_rect.xscale) - hsp ))
    local DeltaY = _circle.y - math.max( (_rect.y - _rect.yoffset*_rect.yscale) - vsp, math.min(_circle.y, (_rect.y + _rect.yoffset*_rect.yscale) - vsp ))
    return (DeltaX^2 + DeltaY^2) < (_circle.r^2)
end

-- Collision CIRCLE <-> CIRCLE
function collision_circle_cirlce(x1, y1, x2, y2, cr, cr2)
    return math.sqrt( (x1 - x2)^2 + (y1 - y2)^2 ) < cr + cr2
end

--- Points
-- Collision BOX <-> POINT
function point_in_box(px, py, box)
    return math.abs(px - box.x) < box.w and
           math.abs(py - box.y) < box.h
end

-- Collision POINT <-> CIRCLE
function point_in_circle(px, py, cx, cy, cr)
    return math.sqrt( (px - cx)^2 + (py - cy)^2 ) < cr
end
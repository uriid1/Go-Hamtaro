--
local serialize = {};

--
local pairs = pairs;
local type  = type;
local tostring = tostring;
local tonumber = tonumber;

-- Recursive serialization
local serialize_map = {
  [ "boolean" ] = tostring,
  [ "string"  ] = function(v) return "'"..tostring(v).."'" end,
  [ "number"  ] = function(v)
    if      (v ~=  v)     then return  "0/0";      --  nan
    elseif  (v ==  1 / 0) then return  "1/0";      --  inf
    elseif  (v == -1 / 0) then return "-1/0"; end  -- -inf
    return tostring(v)
  end,
  [ "table"   ] = function(tbl)
    local tmp = {};
    for k, v in pairs(tbl) do 
      tmp[#tmp + 1] = "[" .. serialize.create(k) .. "]=" .. serialize.create(v); 
    end
    return "{" ..  table.concat(tmp, ",") .. "}";
  end
}

-- Serialize Table
function serialize.create(tbl)
    return serialize_map[type(tbl)](tbl);
end

-- Load Table
function serialize.load(fname)
    local tmp_file = love.filesystem.read(fname);
    return assert((loadstring or load)("return"..tmp_file))();
end

-- Save Table
function serialize.save(tbl, fname)
    love.filesystem.write(fname, serialize_map[type(tbl)](tbl));
end

return serialize;
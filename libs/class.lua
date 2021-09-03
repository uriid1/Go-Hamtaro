--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--

local class = {};
class.__index = class;

function class:newClass() end

function class:extend()
  local tmp = {};
  for k, v in pairs(self) do
    -- Ищем __call и __index
    -- присваиваем врменной таблице
    if (k:find("__") == 1) then
      tmp[k] = v;
    end
  end
  -- Наследуем прототип
  tmp.__index = tmp;
  tmp.class = self;
  setmetatable(tmp, self);
  return tmp;
end

function class:__call(...)
  local obj = setmetatable({}, self);
  obj:newClass(...);
  return obj;
end

return class
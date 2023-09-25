local pi   = math.pi;
local sin  = math.sin;
local cos  = math.cos;
local pow  = math.pow;
local sqrt = math.sqrt;
local abs  = math.abs;

local c1 = 1.70158;
local c2 = c1 * 1.525;
local c3 = c1 + 1;
local c4 = (2 * pi) / 3;
local c5 = (2 * pi) / 4.5;

local n1 = 7.5625;
local d1 = 2.75;

local easing = {};
--{
------- SINE -------
easing.in_sine     = function(t) return sin((pi/2) * t); end
easing.out_sine    = function(t) return sin((t * pi) / 2); end
easing.in_out_sine = function(t) return -(cos(pi * t) - 1) / 2; end
----------------------

------- CUBIC -------
easing.in_cubic     = function(t) return t * t * t; end
easing.out_cubic    = function(t) return 1 - pow(1 - t, 3); end
easing.in_out_cubic = function(t) return (t < 0.5) and 4 * t * t * t or 1 - pow(-2 * t + 2, 3) / 2; end
----------------------

------- QUINT -------
easing.in_quint     = function(t) return t * t * t * t * t; end
easing.out_quint    = function(t) return 1 - pow(1 - t, 5); end
easing.in_out_quint = function(t) return (t < 0.5) and 16 * t * t * t * t * t or 1 - pow(-2 * t + 2, 5) / 2; end
----------------------

------- CIRC -------
easing.in_circ     = function(t) return 1 - sqrt(1 - pow(t, 2)); end
easing.out_circ    = function(t) return sqrt(1 - pow(t - 1, 2)); end
easing.in_out_circ = function(t) return (t < 0.5) and (1 - sqrt(1 - pow(2 * t, 2))) / 2 or (sqrt(1 - pow(-2 * t + 2, 2)) + 1) / 2; end
----------------------

------- ELASTIC -------
easing.in_elastic     = function(t) return (t == 0) and 0 or (t == 1) and 1 or -pow(2, 10 * t - 10) * sin((t * 10 - 10.75) * c4); end
easing.out_elastic    = function(t) return (t == 0) and 0 or (t == 1) and 1 or pow(2, -10 * t) * sin((t * 10 - 0.75) * c4) + 1; end
easing.in_out_elastic = function(t)
    return (t == 0) and 0 or (t == 1) and 1 or (t < 0.5)
           and -(pow(2, 20 * t - 10) * sin((20 * t - 11.125) * c5)) / 2
                or (pow(2, -20 * t + 10) * sin((20 * t - 11.125) * c5)) / 2 + 1;
end
----------------------

------- QUAD -------
easing.in_quad     = function(t) return t * t; end
easing.out_quad    = function(t) return 1 - (1 - t) * (1 - t); end
easing.in_out_quad = function(t) return (t < 0.5) and 2 * t * t or 1 - pow(-2 * t + 2, 2) / 2; end
----------------------

------- QUART -------
easing.in_quart     = function(t) return t * t * t * t; end
easing.out_quart    = function(t) return 1 - pow(1 - t, 4); end
easing.in_out_quart = function(t) return (t < 0.5) and 8 * t * t * t * t or 1 - math.pow(-2 * t + 2, 4) / 2; end
----------------------

------- EXPO -------
easing.in_expo     = function(t) return (t == 0) and 0 or pow(2, 10 * t - 10); end
easing.out_expo    = function(t) return (t == 1) and 1 or 1 - pow(2, -10 * t); end
easing.in_out_expo = function(t)
    return (t == 0) and 0 or (t == 1) and 1
        or (t < 0.5) and pow(2, 20 * t - 10) / 2
        or (2 - pow(2, -20 * t + 10)) / 2;
end
----------------------

------- BACK -------
easing.in_back     = function(t) return c3 * t * t * t - c1 * t * t; end
easing.out_back    = function(t) return 1 + c3 * pow(t - 1, 3) + c1 * pow(t - 1, 2); end
easing.in_out_back = function(t)
  return (t < 0.5) and (pow(2 * t, 2) * ((c2 + 1) * 2 * t - c2)) / 2
      or (pow(2 * t - 2, 2) * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2;
end
----------------------

------- BOUNCE -------
easing.in_bounce     = function(t) return pow(2, 6 * (t - 1)) * abs(sin(t * pi * 3.5)); end
easing.out_bounce    = function(t) return 1 - pow(2, -6 * t) * abs(cos(t * pi * 3.5));  end
easing.in_out_bounce = function(t)
  if (t < 0.5) then
    return 8 * pow(2, 8 * (t - 1)) * abs(sin( t * pi * 7));
  else
    return 1 - 8 * pow(2, -8 * t) * abs(sin( t * pi * 7));
  end
end
----------------------
--}

return easing;
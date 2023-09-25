function love.conf(t)
    t.version               = "11.3";
    t.console               = false;

    -- Mobile
    t.accelerometerjoystick = true;
    t.externalstorage       = true;

    t.gammacorrect          = false;
    t.window.title          = "Go! Hamtaro";
    t.window.width          = 720;
    t.window.height         = 810;
    t.window.minwidth       = t.window.width;
    t.window.minheight      = t.window.height;
    t.window.borderless     = false;
    t.window.resizable      = true;
    t.window.fullscreen     = false;
    t.window.fullscreentype = "desktop";
    t.window.vsync          = 1;
    t.window.msaa           = 0;
    t.window.depth          = nil;
    t.window.stencil        = nil;
    t.window.display        = 1;
    t.window.highdpi        = false;
    t.window.usedpiscale    = true;
end
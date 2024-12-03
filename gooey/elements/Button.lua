local Button = {};

Button.__index = Button;

local button_tex_up = love.graphics.newImage("textures/button.png");
local button_tex_down = love.graphics.newImage("textures/button_down.png");

local BORDER_W = 9;
local BORDER_S = BORDER_W / 3;

button_tex_up:setFilter("nearest");
button_tex_down:setFilter("nearest");

local TL_quad = love.graphics.newQuad(0,0, 3,3, 8,8);
local TR_quad = love.graphics.newQuad(5,0, 3,3, 8,8);
local BR_quad = love.graphics.newQuad(5,5, 3,3, 8,8);
local BL_quad = love.graphics.newQuad(0,5, 3,3, 8,8);
local T_quad = love.graphics.newQuad(4,0, 2,3, 8,8);
local R_quad = love.graphics.newQuad(5,4, 3,2, 8,8);
local B_quad = love.graphics.newQuad(4,5, 2,3, 8,8);
local L_quad = love.graphics.newQuad(0,4, 3,2, 8,8);
local center_quad = love.graphics.newQuad(3,3, 2,2, 8,8);

function Button.new(container, x, y, w, h)
    assert(isNum(x, y, w, h), "bad arguments to create 'Button'");
    assert(w >= BORDER_W and h >= BORDER_W, "button must be at least " .. tostring(BORDER_W * 2) .. "x" .. tostring(BORDER_W * 2) .. " pixels");

    local instance = setmetatable({}, Button);

    instance.x = x;
    instance.y = y;
    instance.w = w;
    instance.h = h;

    instance.hovering = false;
    instance.down = false;

    container:addElement(instance);
    container:claimIn(instance, x, y, x + w, y + h)

    return instance;
end

function Button:setClickCallback(func)
    assert(isFunction(func), "cannot set button's click callback to a non function");

    self.onRelease = func;

    return self; -- allow chain calling
end

function Button:mouseMoved(x, y)
    love.mouse.setCursor();
    self.hovering = false;

    if x < self.x or self.x + self.w <= x then
        return;
    end
    if y < self.y or self.y + self.h <= y then
        return;
    end

    love.mouse.setCursor(love.mouse.getSystemCursor('hand'));
    self.hovering = true;
end
function Button:mousePressed(x, y, button, presses)
    if button ~= 1 then
        return;
    end

    if x < self.x or self.x + self.w <= x then
        return;
    end
    if y < self.y or self.y + self.h <= y then
        return;
    end

    self.down = true;
end
function Button:mouseReleased(x, y, button, presses)
    if button ~= 1 then
        return;
    end

    if not self.down then
        return;
    end

    self.down = false;

    if x < self.x or self.x + self.w <= x then
        return;
    end
    if y < self.y or self.y + self.h <= y then
        return;
    end

    if self.onRelease then
        self.onRelease();
    end
end

function Button:draw()
    love.graphics.setColor(1,1,1);

    local cmp_w = self.w / 2 - BORDER_W;
    local cmp_h = self.h / 2 - BORDER_W;

    if self.down then
        love.graphics.draw(button_tex_down, TL_quad,
            self.x                    , self.y                    , 0, BORDER_S);
        love.graphics.draw(button_tex_down, TR_quad,
            self.x + self.w - BORDER_W, self.y                    , 0, BORDER_S);
        love.graphics.draw(button_tex_down, BR_quad,
            self.x + self.w - BORDER_W, self.y + self.h - BORDER_W, 0, BORDER_S);
        love.graphics.draw(button_tex_down, BL_quad,
            self.x                    , self.y + self.h - BORDER_W, 0, BORDER_S);

        love.graphics.draw(button_tex_down, T_quad,
            self.x + BORDER_W         , self.y                    , 0, cmp_w   , BORDER_S);
        love.graphics.draw(button_tex_down, R_quad,
            self.x + self.w - BORDER_W, self.y + BORDER_W         , 0, BORDER_S, cmp_h   );
        love.graphics.draw(button_tex_down, B_quad,
            self.x + BORDER_W         , self.y + self.h - BORDER_W, 0, cmp_w   , BORDER_S);
        love.graphics.draw(button_tex_down, L_quad,
            self.x                    , self.y + BORDER_W         , 0, BORDER_S, cmp_h   );

        love.graphics.draw(button_tex_down, center_quad,
            self.x + BORDER_W, self.y + BORDER_W, 0, cmp_w, cmp_h);
    else
        love.graphics.draw(button_tex_up, TL_quad,
            self.x                    , self.y                    , 0, BORDER_S);
        love.graphics.draw(button_tex_up, TR_quad,
            self.x + self.w - BORDER_W, self.y                    , 0, BORDER_S);
        love.graphics.draw(button_tex_up, BR_quad,
            self.x + self.w - BORDER_W, self.y + self.h - BORDER_W, 0, BORDER_S);
        love.graphics.draw(button_tex_up, BL_quad,
            self.x                    , self.y + self.h - BORDER_W, 0, BORDER_S);

        love.graphics.draw(button_tex_up, T_quad,
            self.x + BORDER_W         , self.y                    , 0, cmp_w   , BORDER_S);
        love.graphics.draw(button_tex_up, R_quad,
            self.x + self.w - BORDER_W, self.y + BORDER_W         , 0, BORDER_S, cmp_h   );
        love.graphics.draw(button_tex_up, B_quad,
            self.x + BORDER_W         , self.y + self.h - BORDER_W, 0, cmp_w   , BORDER_S);
        love.graphics.draw(button_tex_up, L_quad,
            self.x                    , self.y + BORDER_W         , 0, BORDER_S, cmp_h   );

        love.graphics.draw(button_tex_up, center_quad,
            self.x + BORDER_W, self.y + BORDER_W, 0, cmp_w, cmp_h);
    end
end

return setmetatable({}, {__call = function(_, ...) return Button.new(...) end});
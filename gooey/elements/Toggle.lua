local Toggle = {};

Toggle.__index = Toggle;

local toggle_tex = love.graphics.newImage("gooey/textures/toggle.png");

local BORDER_W = 9;
local BORDER_S = BORDER_W / 3;

toggle_tex:setFilter("nearest");

local TL_quad = love.graphics.newQuad(0,0, 3,3, 8,8);
local TR_quad = love.graphics.newQuad(5,0, 3,3, 8,8);
local BR_quad = love.graphics.newQuad(5,5, 3,3, 8,8);
local BL_quad = love.graphics.newQuad(0,5, 3,3, 8,8);
local T_quad = love.graphics.newQuad(4,0, 2,3, 8,8);
local R_quad = love.graphics.newQuad(5,4, 3,2, 8,8);
local B_quad = love.graphics.newQuad(4,5, 2,3, 8,8);
local L_quad = love.graphics.newQuad(0,4, 3,2, 8,8);
local center_quad = love.graphics.newQuad(3,3, 2,2, 8,8);

function Toggle.new(x, y, w, h)
    assert(isNum(x, y, w, h), "bad arguments to create 'Toggle'");
    assert(w >= BORDER_W and h >= BORDER_W, "button must be at least " .. tostring(BORDER_W * 2) .. "x" .. tostring(BORDER_W * 2) .. " pixels");

    local instance = setmetatable({}, Toggle);

    instance.x = x;
    instance.y = y;
    instance.w = w;
    instance.h = h;

    instance.active = false;
    instance.down = false;

    return instance;
end

function Toggle:mouseMoved(x, y)
    love.mouse.setCursor();

    if x < self.x or self.x + self.w <= x then
        return;
    end
    if y < self.y or self.y + self.h <= y then
        return;
    end

    love.mouse.setCursor(love.mouse.getSystemCursor('hand'));
end
function Toggle:mousePressed(x, y, button, presses)
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
function Toggle:mouseReleased(x, y, button, presses)
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

    self.active = not self.active;
end

function Toggle:draw()
    love.graphics.setColor(1,1,1);

    local cmp_w = self.w / 2 - BORDER_W;
    local cmp_h = self.h / 2 - BORDER_W;

    love.graphics.draw(toggle_tex, TL_quad, self.x                    , self.y                    , 0, BORDER_S);
    love.graphics.draw(toggle_tex, TR_quad, self.x + self.w - BORDER_W, self.y                    , 0, BORDER_S);
    love.graphics.draw(toggle_tex, BR_quad, self.x + self.w - BORDER_W, self.y + self.h - BORDER_W, 0, BORDER_S);
    love.graphics.draw(toggle_tex, BL_quad, self.x                    , self.y + self.h - BORDER_W, 0, BORDER_S);

    love.graphics.draw(toggle_tex, T_quad, self.x + BORDER_W         , self.y                    , 0, cmp_w   , BORDER_S);
    love.graphics.draw(toggle_tex, R_quad, self.x + self.w - BORDER_W, self.y + BORDER_W         , 0, BORDER_S, cmp_h   );
    love.graphics.draw(toggle_tex, B_quad, self.x + BORDER_W         , self.y + self.h - BORDER_W, 0, cmp_w   , BORDER_S);
    love.graphics.draw(toggle_tex, L_quad, self.x                    , self.y + BORDER_W         , 0, BORDER_S, cmp_h   );

    love.graphics.draw(toggle_tex, center_quad, self.x + BORDER_W, self.y + BORDER_W, 0, cmp_w, cmp_h);

    if self.active then
        love.graphics.setColor(0.5, 0.5, 0.5);
        love.graphics.rectangle("fill", self.x + 1.5 * BORDER_W, self.y + 1.5 * BORDER_W, self.w - 3 * BORDER_W, self.h - 3 * BORDER_W);
    end
end

return setmetatable({}, {__call = function(_, ...) return Toggle.new(...) end});

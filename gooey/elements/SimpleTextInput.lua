local SimpleTextInput = {};

SimpleTextInput.__index = SimpleTextInput;

local text_tex = love.graphics.newImage("textures/text_input.png");

local BORDER_W = 9;
local BORDER_S = BORDER_W / 3;

text_tex:setFilter("nearest");

local TL_quad =     love.graphics.newQuad(0,0, 3,3, 8,8);
local TR_quad =     love.graphics.newQuad(5,0, 3,3, 8,8);
local BR_quad =     love.graphics.newQuad(5,5, 3,3, 8,8);
local BL_quad =     love.graphics.newQuad(0,5, 3,3, 8,8);
local T_quad =      love.graphics.newQuad(4,0, 2,3, 8,8);
local R_quad =      love.graphics.newQuad(5,4, 3,2, 8,8);
local B_quad =      love.graphics.newQuad(4,5, 2,3, 8,8);
local L_quad =      love.graphics.newQuad(0,4, 3,2, 8,8);
local center_quad = love.graphics.newQuad(3,3, 2,2, 8,8);

function SimpleTextInput.new(container, x, y, w, h, blankText_font_callback, font_callback, callback)
    assert(isNum(x, y, w, h), "bad arguments to create 'SimpleTextInput'");

    local blankText = nil;
    local font = nil;

    if font_callback then
        if type(font_callback) == "function" then
            callback = font_callback;
        elseif font_callback.type and font_callback:type() == "font" then
            font = font_callback;
        end
    end

    if blankText_font_callback then
        if type(blankText_font_callback) == "function" then
            callback = blankText_font_callback;
        elseif type(blankText_font_callback) == "string" then
            blankText = blankText_font_callback;
        elseif blankText_font_callback.type and blankText_font_callback:type() == "font" then
            font = blankText_font_callback;
        end
    end

    local instance = setmetatable({}, SimpleTextInput);

    instance.x = x;
    instance.y = y;
    instance.w = w;
    instance.h = h;

    instance.curText = "";

    instance.blankText = blankText or "Text input";
    instance.font = font or MONOSPACE_128;

    instance.active = false;

    instance.callback = callback;

    instance.blink = true;
    instance.blinkTimer = 0.5;

    container:addElement(instance);
    container:claimIn(instance, x, y, x + w, y + h);

    return instance;
end

function SimpleTextInput:loseFocus()
    if self.active and self.callback then
        self.callback(self.curText);
    end

    self.active = false;
end

function SimpleTextInput:textInput(text)
    if not self.active then
        return;
    end

    self.curText = self.curText .. text;
end
function SimpleTextInput:keyPressed(key, isRepeat)
    if not self.active then
        return;
    end

    if key == "backspace" then
        self.curText = string.sub(self.curText, 1, -2);
    elseif key == "return" then
        if self.callback then
            self.callback(self.curText);
        end

        self.active = false;
    end
end

function SimpleTextInput:mouseMoved(x, y)
    love.mouse.setCursor();

    if x < self.x or self.x + self.w <= x then
        return;
    end
    if y < self.y or self.y + self.h <= y then
        return;
    end

    love.mouse.setCursor(love.mouse.getSystemCursor('ibeam'));
end
function SimpleTextInput:mousePressed(x, y, button, presses)
    if button ~= 1 then
        return;
    end

    if x < self.x or self.x + self.w <= x then
        if self.active and self.callback then
            self.callback(self.curText);
        end
        self.active = false;

        return;
    end
    if y < self.y or self.y + self.h <= y then
        if self.active and self.callback then
            self.callback(self.curText);
        end
        self.active = false;

        return;
    end

    self.active = true;
end

function SimpleTextInput:update(dt)
    if self.active then
        self.blinkTimer = self.blinkTimer - dt;

        if self.blinkTimer <= 0 then
            self.blink = not self.blink;
            self.blinkTimer = self.blinkTimer % 0.5; -- bound between 0 and 0.5: allow runoff
        end
    else
        self.blink = true;
        self.blinkTimer = 0.5;
    end
end
function SimpleTextInput:draw()
    love.graphics.setColor(1,1,1);
    love.graphics.setFont(self.font);

    local cmp_w = self.w / 2 - BORDER_W;
    local cmp_h = self.h / 2 - BORDER_W;
    local x2cmp_w = cmp_w * 2;
    local tex_s = cmp_h * 2 / self.font:getHeight("|");

    love.graphics.draw(text_tex, TL_quad, self.x                    , self.y                    , 0, BORDER_S);
    love.graphics.draw(text_tex, TR_quad, self.x + self.w - BORDER_W, self.y                    , 0, BORDER_S);
    love.graphics.draw(text_tex, BR_quad, self.x + self.w - BORDER_W, self.y + self.h - BORDER_W, 0, BORDER_S);
    love.graphics.draw(text_tex, BL_quad, self.x                    , self.y + self.h - BORDER_W, 0, BORDER_S);

    love.graphics.draw(text_tex, T_quad, self.x + BORDER_W         , self.y                    , 0, cmp_w   , BORDER_S);
    love.graphics.draw(text_tex, R_quad, self.x + self.w - BORDER_W, self.y + BORDER_W         , 0, BORDER_S, cmp_h   );
    love.graphics.draw(text_tex, B_quad, self.x + BORDER_W         , self.y + self.h - BORDER_W, 0, cmp_w   , BORDER_S);
    love.graphics.draw(text_tex, L_quad, self.x                    , self.y + BORDER_W         , 0, BORDER_S, cmp_h   );

    love.graphics.draw(text_tex, center_quad, self.x + BORDER_W, self.y + BORDER_W, 0, cmp_w, cmp_h);

    if self.active then -- if selected or clicked
        love.graphics.setColor(0,0,0);

        local text, droppedText, addedText = string.formatFront(self.curText .. "_", x2cmp_w, self.font, tex_s);

        if not self.blink then
            text = string.sub(text, 1, -2); -- remove '_' from end
        end

        love.graphics.print(text, self.x + BORDER_W, self.y + BORDER_W, 0, tex_s);
    else
        if self.curText == "" then
            love.graphics.setColor(0.4, 0.4, 0.4);

            local text = string.formatFront(self.blankText, x2cmp_w, self.font, tex_s);

            love.graphics.print(text, self.x + BORDER_W, self.y + BORDER_W, 0, tex_s);
        else
            love.graphics.setColor(0,0,0);

            local text = string.formatFront(self.curText, x2cmp_w, self.font, tex_s);

            love.graphics.print(text, self.x + BORDER_W, self.y + BORDER_W, 0, tex_s)
        end
    end
end

return setmetatable({}, {__call = function(_, ...) return SimpleTextInput.new(...) end});
--* yes: this is all my code (judah cline, pseudonym: milo denote)
--* yes: I wrote all of the stupid ui cursor selection checking
--* yes: there are probably bugs
--* yes: I wasted too much time on this
--* yes: I could've just; not implemented text selection and cursor placement

--* look at the code if you want but this is what normal frontend dev looks like from the backend (its a mess)
--* I tried to comment it but no amount of makeup will hide a pig
--! 491 lines of code and only 490 of them are edge case checking :3 (the one that isnt is this comment X3)

local TextInput = {};

TextInput.__index = TextInput;

local text_tex = love.graphics.newImage("textures/text_input.png");

local BORDER_W = 9;
local x2BORDER_W = BORDER_W * 2;
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

function TextInput.new(container, x, y, w, h, blankText_font_callback, font_callback, callback)
    assert(isNum(x, y, w, h), "bad arguments to create 'TextInput'");

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

    local instance = setmetatable({}, TextInput);

    instance.x = x;
    instance.y = y;
    instance.w = w;
    instance.h = h;

    instance.active = false;
    instance.curText = "";
    instance.blankText = blankText or "Text input";

    instance.minCursor = 0;
    instance.maxCursor = 0;
    instance.downCursor = 0;

    instance.shiftingUp = false;
    instance.shifting = false;
    instance.dragging = false;

    instance.blink = true;
    instance.blinkTimer = 0.5;

    instance.callback = callback;

    instance.font = font or MONOSPACE_128;

    container:addElement(instance);
    container:claimIn(instance, x, y, x + w, y + h);

    return instance;
end

function TextInput:getText()
    return self.curText;
end
function TextInput:setText(text)
    self.curText = text;

    if self.active then
        self.minCursor = string.len(text);
        self.maxCursor = self.minCursor;
    end
end

function TextInput:loseFocus()
    if self.active and self.callback then
        self.callback(self.curText);
    end

    self.active = false; -- when clicking off of the text: stop typing
end

function TextInput:textInput(text)
    if not self.active then
        return; -- dont alter text if not clicked on
    end

    if text ~= "" then
        self.dragging = false; -- when typing: stop holding the cursor
    end

    local textBeforeSelected = string.sub(self.curText, 1                 , self.minCursor);
    local textAfterSelected =  string.sub(self.curText, self.maxCursor + 1, -1            );

    self.curText = textBeforeSelected .. text .. textAfterSelected;

    self.minCursor = self.minCursor + string.len(text);
    self.maxCursor = self.minCursor;
end
function TextInput:keyPressed(key, isRepeat)
    if not self.active then
        return; -- ignore inputs if not clicked on
    end

    if key == "backspace" then -- support for backspace
        self.dragging = false; -- stop dragging

        if self.minCursor == self.maxCursor then -- if user selected text then only delete selected text
            local textBeforeSelected = string.sub(self.curText, 0                 , math.max(0, self.minCursor - 1));
            local textAfterSelected =  string.sub(self.curText, self.maxCursor + 1, -1                             );

            self.curText = textBeforeSelected .. textAfterSelected;

            self.minCursor = math.max(0, self.minCursor - 1);
            self.maxCursor = self.minCursor;
        else -- if no selected text then remove 1 character before cursor
            local textBeforeSelected = string.sub(self.curText, 0                 , self.minCursor); -- NOT minCursor - 1
            local textAfterSelected =  string.sub(self.curText, self.maxCursor + 1, -1            );

            self.curText = textBeforeSelected .. textAfterSelected;

            self.maxCursor = self.minCursor;
        end
    elseif key == "return" then -- support for enter button ending and submitting text input
        if self.active and self.callback then
            self.callback(self.curText);
        end

        self.dragging = false;
        self.active = false;
    elseif key == "left" then -- support for moving cursor using arrow keys
        if love.keyboard.isDown("lshift") then -- if holding shift button then change selected text
            if self.shifting then -- if already performed shift move then use it as a base for 'direction'
                if self.shiftingUp then -- 'direction' of shift move
                    self.maxCursor = math.max(self.minCursor, self.maxCursor - 1);

                    if self.maxCursor == self.minCursor then
                        self.shifting = false;
                    end
                else
                    self.minCursor = math.max(0, self.minCursor - 1);
                end
            else -- if not than start shift move with left 'direction'
                self.shifting = true;
                self.shiftingUp = false;

                self.minCursor = math.max(0, self.minCursor - 1);
            end
        else -- if not shift moveing then move cursor to the left
            self.dragging = false;

            self.minCursor = math.max(0, self.minCursor - 1);
            self.maxCursor = self.minCursor;
        end
    elseif key == "right" then -- support formoving cursor using arrow keys
        if love.keyboard.isDown("lshift") then -- if holding shift button then change selected text
            if self.shifting then -- if already performed shift move then use it as a base for 'direction'
                if self.shiftingUp then -- 'direction' of shift move
                    self.maxCursor = math.min(string.len(self.curText), self.maxCursor + 1);
                else
                    self.minCursor = math.min(string.len(self.curText), self.minCursor + 1);

                    if self.maxCursor == self.minCursor then
                        self.shifting = false;
                    end
                end
            else -- if not than start shift move with right 'direction'
                self.shifting = true;
                self.shiftingUp = true;

                self.maxCursor = math.min(string.len(self.curText), self.maxCursor + 1);
            end
        else -- if not shift moveing then move cursor to the right
            self.dragging = false;

            self.minCursor = math.min(string.len(self.curText), self.maxCursor + 1);
            self.maxCursor = self.minCursor;
        end
    elseif key == "v" then -- support for paste command: ctrl + v
        if not love.keyboard.isDown("lctrl") then
            return; -- if not holding ctrl than no command is inputted (never nester blood)
        end

        local textBeforeSelected = string.sub(self.curText, 0                 , self.minCursor);
        local textAfterSelected =  string.sub(self.curText, self.maxCursor + 1, -1            );
        local clipboardText = love.system.getClipboardText();

        self.curText = textBeforeSelected .. clipboardText .. textAfterSelected;

        self.minCursor = self.minCursor + string.len(clipboardText);
        self.maxCursor = self.minCursor;
    elseif key == "c" then -- support for copy command: ctrl + c
        if not love.keyboard.isDown("lctrl") then
            return; -- if not holding ctrl than no command is inputted (never nester blood)
        end

        if self.minCursor == self.maxCursor then -- if not selecting text than use all text in the textbox
            love.system.setClipboardText(self.curText);
        else -- if selecting text than use selected text
            love.system.setClipboardText(string.sub(self.curText, self.minCursor + 1, self.maxCursor));
        end
    elseif key == "x" then -- support for cut command: ctrl + x
        if not love.keyboard.isDown("lctrl") then
            return; -- if not holding ctrl than no command is inputted (never nester blood)
        end

        if self.minCursor == self.maxCursor then -- if not selecting text than cut all text in textbox
            love.system.setClipboardText(self.curText);

            self.curText = "";
        else -- if selecting text than cut selected text
            love.system.setClipboardText(string.sub(self.curText, self.minCursor + 1, self.maxCursor));

            local textBeforeSelected = string.sub(self.curText, 0                 , self.minCursor);
            local textAfterSelected =  string.sub(self.curText, self.maxCursor + 1, -1            );

            self.curText = textBeforeSelected .. textAfterSelected;

            self.maxCursor = self.minCursor;
        end
    end
end

function TextInput:mouseMoved(x, y)
    if self.dragging then -- if selecting text
        local fText, droppedText, addedText = string.formatFront(
            self.curText,
            self.w - x2BORDER_W,
            self.font,
            (self.h - x2BORDER_W) / self.font:getHeight("|")
        );

        local secondPos = string.getNearPosition(
            fText,
            x - self.x - BORDER_W,
            self.font,
            (self.h - x2BORDER_W) / self.font:getHeight("|")
        );

        secondPos = secondPos - string.len(addedText);

        if secondPos == -1 then
            secondPos = 0;
        end

        secondPos = secondPos + string.len(droppedText);

        self.minCursor = math.min(self.downCursor, secondPos);
        self.maxCursor = math.max(self.downCursor, secondPos);

        love.mouse.setCursor(love.mouse.getSystemCursor('ibeam')); -- set cursor to I beam
        return;
    end

    love.mouse.setCursor(); -- set cursor to default arrow

    -- check if in bounds (if not than return)
    if x < self.x or self.x + self.w <= x then
        return;
    end
    if y < self.y or self.y + self.h <= y then
        return;
    end

    love.mouse.setCursor(love.mouse.getSystemCursor('ibeam')); -- set cursor to I beam (is hovering over box)
end
function TextInput:mousePressed(x, y, button, presses)
    if button ~= 1 then
        return; -- if not left click then ignore mouse press
    end

    -- check if in bounds (if not then return)
    if x < self.x or self.x + self.w <= x then
        if self.active and self.callback then
            self.callback(self.curText);
        end
        self.active = false;
        self.dragging = false;

        return;
    end
    if y < self.y or self.y + self.h <= y then
        if self.active and self.callback then
            self.callback(self.curText);
        end
        self.active = false;
        self.dragging = false;

        return;
    end

    local fText, droppedText, addedText = string.formatFront(
        self.curText,
        self.w - x2BORDER_W,
        self.font,
        (self.h - x2BORDER_W) / self.font:getHeight("|")
    );

    local firstPos = string.getNearPosition(
        fText,
        x - self.x - BORDER_W,
        self.font,
        (self.h - x2BORDER_W) / self.font:getHeight("|")
    );
    firstPos = math.max(0, firstPos - string.len(addedText));

    local previousDownCursor = self.downCursor;
    self.downCursor = string.len(droppedText) + firstPos;

    if self.active and love.keyboard.isDown("lshift") then -- shift clicking between spots should select text
        if self.minCursor == self.maxCursor then -- if not selecting
            if self.downCursor < self.minCursor then
                self.minCursor = self.downCursor;
                self.downCursor = self.maxCursor; -- make previous cursor pos the drag from spot
            else
                self.maxCursor = self.downCursor;
                self.downCursor = self.minCursor; -- make previous cursor pos the drag from spot
            end
        else -- if already selecting
            if self.minCursor == previousDownCursor then
                self.maxCursor = self.downCursor;
                self.downCursor = previousDownCursor;
            elseif self.maxCursor == previousDownCursor then
                self.minCursor = self.downCursor;
                self.downCursor = previousDownCursor;
            else
                self.maxCursor = self.downCursor;
                self.downCursor = self.minCursor;
            end
        end
    else
        self.minCursor = self.downCursor;
        self.maxCursor = self.downCursor;
    end

    -- set flags for dragging and pressed
    self.dragging = true;
    self.active = true;
end
function TextInput:mouseReleased(x, y, button, presses)
    if not self.dragging then
        return; -- if user isn not dragging then nothing will change
    end

    if button ~= 1 then
        return; -- ignore if left button was not released
    end

    local fText, droppedText, addedText = string.formatFront(
        self.curText,
        self.w - x2BORDER_W,
        self.font,
        (self.h - x2BORDER_W) / self.font:getHeight("|")
    );

    local secondPos = string.getNearPosition(
        fText,
        x - self.x - BORDER_W,
        self.font,
        (self.h - x2BORDER_W) / self.font:getHeight("|")
    );
    secondPos = secondPos - string.len(addedText);

    if secondPos == -1 then
        secondPos = 0;
    end

    if secondPos == -2 then
        secondPos = 0;
    else
        secondPos = string.len(droppedText) + secondPos;
    end

    self.minCursor = math.min(self.downCursor, secondPos);
    self.maxCursor = math.max(self.downCursor, secondPos);

    self.dragging = false; -- stop dragging
end

function TextInput:update(dt)
    if self.active then -- blink the selection if active, if not then reset the blink
        self.blinkTimer = self.blinkTimer - dt;

        if self.blinkTimer <= 0 then
            self.blink = not self.blink;
            self.blinkTimer = self.blinkTimer % 0.5; -- bound between 0 and 0.5: allow runoff
        end
    else
        self.blinkTimer = 0.5;
        self.blink = true;
    end
end
function TextInput:draw()
    love.graphics.setColor(1,1,1);
    love.graphics.setFont(self.font);

    local cmp_w = self.w / 2 - BORDER_W;
    local cmp_h = self.h / 2 - BORDER_W;
    local x2cmp_w = cmp_w * 2;
    local x2cmp_h = cmp_h * 2;
    local tex_s = x2cmp_h / self.font:getHeight("|");

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

        local text, droppedText, addedText = string.formatFront(self.curText, x2cmp_w, self.font, tex_s);
        love.graphics.print(text, self.x + BORDER_W, self.y + BORDER_W, 0, tex_s);

        if self.minCursor == self.maxCursor then -- if not selecting text then draw beam
            local beam_blink = self.blink and "|" or ""; -- lua ternary, if blinking then use '|' else use empty string

            local sx_p =  self.font:getWidth(string.sub(self.curText, 0, self.minCursor));
            sx_p = sx_p - self.font:getWidth(droppedText);
            sx_p = sx_p + self.font:getWidth(addedText);
            sx_p = sx_p * tex_s

            local I_x = self.x + BORDER_W + sx_p - self.font:getWidth("|") * tex_s / 2;
            love.graphics.print(beam_blink, I_x, self.y + BORDER_W, 0, tex_s);
        else
            love.graphics.setColor(0.3, 0.5, 1, 0.3);

            local disp_cursorPos = math.max(self.minCursor, string.len(droppedText) - 2);

            local sx_p =  self.font:getWidth(string.sub(self.curText, 0, disp_cursorPos));
            sx_p = sx_p - self.font:getWidth(droppedText);
            sx_p = sx_p + self.font:getWidth(addedText);
            sx_p = sx_p * tex_s;

            local ex_p =  self.font:getWidth(string.sub(self.curText, 0, self.maxCursor));
            ex_p = ex_p - self.font:getWidth(droppedText);
            ex_p = ex_p + self.font:getWidth(addedText);
            ex_p = ex_p * tex_s;

            love.graphics.rectangle("fill", self.x + BORDER_W + sx_p, self.y + BORDER_W, ex_p - sx_p, x2cmp_h);
        end
    else
        if self.curText == "" then
            love.graphics.setColor(0.4, 0.4, 0.4);

            local text = string.formatBack(self.blankText, x2cmp_w, self.font, tex_s);

            love.graphics.print(text, self.x + BORDER_W, self.y + BORDER_W, 0, tex_s);
        else
            love.graphics.setColor(0,0,0);

            local text = string.formatFront(self.curText, x2cmp_w, self.font, tex_s);

            love.graphics.print(text, self.x + BORDER_W, self.y + BORDER_W, 0, tex_s)
        end
    end
end

return setmetatable({}, {__call = function(_, ...) return TextInput.new(...) end});
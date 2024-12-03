local RadioButton = {};

RadioButton.__index = RadioButton;

local gradient_tex = love.graphics.newImage("textures/gradient.png");

gradient_tex:setFilter("nearest");

local MESH = nil;

if true then
    local verts = {};

    for i = 0, 50 do
        local dir = math.pi * 2 * (0.125 + i / 50);

        local cos = math.cos(dir);
        local sin = math.sin(dir);

        table.insert(verts, {cos / 2 + 0.5, sin / 2 + 0.5, 1 - i / 50,0});
        table.insert(verts, {0.5, 0.5, 1 - i / 50,1});
    end

    MESH = love.graphics.newMesh(verts, "strip", "static");
    MESH:setTexture(gradient_tex);
end

local PIXEL_S = 3;

function RadioButton.new(container, x, y, w, h, numOptions)
    assert(isNum(x, y, w, h), "bad arguments to create 'RadioButton'");
    numOptions = numOptions or 1;

    local instance = setmetatable({}, RadioButton);

    instance.x = x;
    instance.y = y;
    instance.w = w;
    instance.h = h;

    instance.numOptions = numOptions;
    instance.curSelect = nil;
    instance.downOn = nil;

    container:addElement(instance);
    container:claimIn(instance, x, y, x + w, y + h * numOptions + (h / 2) * (numOptions - 1));

    return instance;
end

function RadioButton:mouseMoved(x, y)
    love.mouse.setCursor();

    if x < self.x or self.x + self.w <= x then
        return;
    end

    for i = 1, self.numOptions do
        local bNy = self.y + (i - 1) * self.h * 1.5;
        local tNy = bNy + self.h;

        if bNy < y and y <= tNy then
            love.mouse.setCursor(love.mouse.getSystemCursor('hand'));

            break;
        end
    end
end
function RadioButton:mousePressed(x, y, button, presses)
    if button ~= 1 then
        return;
    end

    if x < self.x or self.x + self.w <= x then
        return;
    end

    for i = 1, self.numOptions do
        local bNy = self.y + (i - 1) * self.h * 1.5;
        local tNy = bNy + self.h;

        if bNy < y and y <= tNy then
            self.downOn = i;

            break;
        end
    end
end
function RadioButton:mouseReleased(x, y, button, presses)
    if button ~= 1 then
        return;
    end

    if x < self.x or self.x + self.w <= x then
        return;
    end

    for i = 1, self.numOptions do
        local bNy = self.y + (i - 1) * self.h * 1.5;
        local tNy = bNy + self.h;

        if bNy < y and y <= tNy then
            if i == self.downOn then
                self.curSelect = i;
            end

            break;
        end
    end

    self.downOn = nil;
end

function RadioButton:draw()
    love.graphics.setColor(1,1,1);

    for i = 1, self.numOptions do
        love.graphics.draw(MESH, self.x, self.y + (i - 1) * self.h * 1.5, 0, self.w, self.h);

        if self.curSelect == i then
            love.graphics.setColor(0,0,0);
            love.graphics.circle("fill", self.x + self.w / 2, self.y + (i - 2/3) * self.h * 1.5, self.w / 10 * 3);
            love.graphics.setColor(1,1,1);
        end
    end
end

return setmetatable({}, {__call = function(_, ...) return RadioButton.new(...) end});
print("loading gooey elements...");
for i, filename in ipairs(love.filesystem.getDirectoryItems("gooey_/elements")) do
    local globalName = string.match(filename, "^(.*)%.lua$");

    if globalName then
        print(globalName);
        globalize(globalName, require("gooey_/elements/" .. globalName));
    end
end
print("finished loading gooey elements");

local ElementContainer = require("gooey_/elementContainer");

local Gooey = {};

Gooey.__index = Gooey;

function Gooey.new()
    local instance = setmetatable({}, Gooey);

    instance.world = {}; -- table of element containers

    return instance;
end

function Gooey:newContainer(x, y, gridSize, _maxWidth, _maxheight)
    local newCont = ElementContainer.new(x, y, gridSize, _maxWidth, _maxheight);

    table.insert(self.world, newCont);

    return newCont;
end

function Gooey:textinput(text)
    for i, v in ipairs(self.world) do
        if v.active then
            v:textinput(text);
        end
    end
end
function Gooey:keypressed(key, scancode, isrepeat)
    for i, v in ipairs(self.world) do
        if v.active then
            v:keypressed(key, scancode, isrepeat);
        end
    end
end
function Gooey:keyreleased(key, scancode)
    for i, v in ipairs(self.world) do
        if v.active then
            v:keyreleased(key, scancode);
        end
    end
end

function Gooey:mousemoved(x, y, dx, dy, isTouch)
    for i, v in ipairs(self.world) do
        if v.active then
            v:mousemoved(x, y, dx, dy, isTouch);
        end
    end
end
function Gooey:mousepressed(x, y, button, isTouch, presses)
    for i, v in ipairs(self.world) do
        if v.active then
            v:mousepressed(x, y, button, isTouch, presses);
        end
    end
end
function Gooey:mousereleased(x, y, button, isTouch, presses)
    for i, v in ipairs(self.world) do
        if v.active then
            v:mousereleased(x, y, button, isTouch, presses);
        end
    end
end
function Gooey:wheelmoved(x, y)
    for i, v in ipairs(self.world) do
        if v.active then
            v:wheelmoved(x, y);
        end
    end
end

function Gooey:update(dt)
    for i, v in ipairs(self.world) do
        if v.active then
            v:update(dt);
        end
    end
end
function Gooey:draw()
    for i, v in ipairs(self.world) do
        if v.active then
            v:draw();
        end
    end
end

return Gooey.new();
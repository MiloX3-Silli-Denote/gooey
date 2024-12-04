--? global stuffs :3

--* constants
math.tau = 2 * math.pi;
math.roottwo = math.sqrt(2);

--* math
function math.clamp(k, min, max)
    assert(min <= max, "cannot clamp, min is greater than max");

    if k < min then
        return min;
    elseif k > max then
        return max;
    else
        return k;
    end
end
function math.lerp(a, b, t)
    t = math.clamp(t, 0, 1);

    return a + (a - b) * t;
end
function math.angle(cx, cy, px, py)
    return math.atan2(cy - py, cx - px) % math.tau;
end
function math.pointInRect(px, py, rx, ry, rw, rh)
    if px >= rx and py >= ry and px < px + rw and py < ry + rh then
        return true;
    end

    return false;
end

--* table
function table.flatten(a)
    local ret = {};

    for i, v in ipairs(a) do
        if isLump(v) then
            for j, w in ipairs(table.flatten(v)) do
                table.insert(ret, w);
            end
        else
            table.insert(ret, v);
        end
    end

    return ret;
end
function table.back(a)
    return a[#a];
end
function table.front(a)
    return a[1];
end
function table.copy(a)
    local ret = {};

    for k, v in pairs(a) do
        if type(v) == "table" then
            ret[k] = table.copy(v);
        else
            ret[k] = v;
        end
    end

    return ret;
end
function table.duplicate(a, k)
    local ret = {};

    for i = 1, k do
        ret[i] = a;
    end
end

--* string
function string.getNumberOrByte(str)
    assert(string.len(str) == 1, "cannot get number or byte from string longer than one character");

    if string.find(str, "[1-9]") then
        return tonumber(str);
    end

    if string.find(str, "%l") then
        return string.byte(str) - 96;
    end
end
function string.split(a, reg)
    local ret = {};

    for str in string.gmatch(a, reg) do
        table.insert(ret, str);
    end

    return ret;
end

function string.formatBack(text, width, font, scale)
    font = font or love.graphics.getFont();

    if font:getWidth(text) * scale <= width then
        return text, "", "";
    end

    if font:getWidth("..") * scale > width then
        if font:getWidth(".") * scale > width then
            return "", text, "";
        else
            return ".", text, ".";
        end
    end

    for i = 1, string.len(text) do
        if font:getWidth(string.sub(text, 0, i) .. "..") * scale > width then
            return string.sub(text, 0, i - 1) .. "..", string.sub(text, i, -1), "..";
        end
    end

    return text, "", ""; -- should never reach here
end
function string.formatFront(text, width, font, scale)
    font = font or love.graphics.getFont();

    if font:getWidth(text) * scale <= width then
        return text, "", "";
    end

    if font:getWidth("..") * scale > width then
        if font:getWidth(".") * scale > width then
            return "", text, "";
        else
            return ".", text, ".";
        end
    end

    local len = string.len(text);

    for i = 1, string.len(text) do
        if font:getWidth(".." .. string.sub(text, len - i, len)) * scale > width then
            return ".." .. string.sub(text, len - i + 1, len), string.sub(text, 0, len - i), "..";
        end
    end

    return text, "", ""; -- should never reach here
end
function string.getLowPosition(text, xPos, font, scale)
    if xPos < 0 then
        return 0;
    end

    font = font or love.graphics.getFont();

    if font:getWidth(text) * scale <= xPos then
        return string.len(text);
    end

    for i = 1, string.len(text) do
        if font:getWidth(string.sub(text, 1, i)) * scale > xPos then
            return i - 1;
        end
    end

    return string.len(text);
end
function string.getHighPosition(text, xPos, font, scale)
    if xPos < 0 then
        return 0;
    end

    font = font or love.graphics.getFont();

    if font:getWidth(text) * scale <= xPos then
        return string.len(text);
    end

    for i = 1, string.len(text) do
        if font:getWidth(string.sub(text, 1, i)) * scale > xPos then
            return i;
        end
    end

    return string.len(text);
end
function string.getNearPosition(text, xPos, font, scale)
    if xPos < 0 then
        return 0;
    end

    font = font or love.graphics.getFont();

    if font:getWidth(text) * scale <= xPos then
        return string.len(text);
    end

    for i = 1, string.len(text) do
        local lowEdge = font:getWidth(string.sub(text, 0, i - 1)) * scale;
        local highEdge = font:getWidth(string.sub(text, 1, i)) * scale;

        if highEdge > xPos then
            if xPos - lowEdge < highEdge - xPos then
                return i - 1;
            else
                return i;
            end
        end
    end

    return string.len(text);
end

--* misc. data
function globalize(name, data)
    assert(isString(name), "cannot set global name as a non string");

    if _G[name] then
        print("WARNING: overwriting global variable: '" .. name .. "' Could have major consequences");
    end

    _G[name] = data;
end
function checkDeep(tbl, ...)
    local args = {...};

    local cur = tbl;

    while #args > 0 do
        if isTable(cur) then
            cur = cur[table.remove(args, 1)];
        else
            return false;
        end
    end

    if cur then
        return true;
    else
        return false;
    end
end
function getObjectCall(obj, func)
    return function(...)
        return func(obj, ...);
    end
end

--* conversions
function boolToNum(a)
    return a and 1 or 0;
end
function boolToSign(a)
    return a and 1 or -1;
end

--* type checking
function isLump(...)
    local args = {...};

    if #args == 0 then
        return false;
    end

    for _, v in ipairs(args) do
        local tpe = type(v);

        if tpe ~= "userdata" and tpe ~= "table" and tpe ~= "cdata" then
            return false;
        end
    end

    return true;
end
function isNilBool(...)
    local args = {...};

    for _, v in ipairs(args) do
        local tpe = type(v);

        if tpe ~= "nil" and tpe ~= "boolean" then
            return false;
        end
    end

    return true;
end
function isNil(...)
    local args = {...};

    if #args == 0 then
        return true;
    end

    return false;
end
function isNum(...)
    local args = {...};

    if #args == 0 then
        return false;
    end

    for _, v in ipairs(args) do
        if type(v) ~= "number" then
            return false;
        end
    end

    return true;
end
function isString(...)
    local args = {...};

    if #args == 0 then
        return false;
    end

    for _, v in ipairs(args) do
        if type(v) ~= "string" then
            return false;
        end
    end

    return true;
end
function isFunction(...)
    local args = {...};

    if #args == 0 then
        return false;
    end

    for _, v in ipairs(args) do
        if type(v) ~= "function" then
            return false;
        end
    end

    return true;
end
function isTable(...)
    local args = {...};

    if #args == 0 then
        return false;
    end

    for _, v in ipairs(args) do
        if type(v) ~= "table" then
            return false;
        end
    end

    return true;
end

--* iterators
function squareIterator(startX, startY, endX, endY)
    if not endX then
        endX = startX;
        startX = 1;
    end

    if not endY then
        endY = startY;
        startY = 1;
    end

    local dirX = endX > startX and 1 or -1;
    local dirY = endY > startY and 1 or -1;

    local curX = startX - dirX;
    local curY = startY;

    return function()
        curX = curX + dirX;

        if curX - dirX == endX then
            curX = startX;
            curY = curY + dirY;
        end

        if curY - dirY ~= endY then
            return curX, curY;
        end
    end
end
function cubeIterator(startX, startY, startZ, endX, endY, endZ)
    if not endX then
        endX = startX;
        startX = 1;
    end

    if not endY then
        endY = startY;
        startY = 1;
    end

    if not endZ then
        endZ = startZ;
        startZ = 1;
    end

    if startX == endX or startY == endY or startZ == endZ then
        return;
    end

    local dirX = endX > startX and 1 or -1;
    local dirY = endY > startY and 1 or -1;
    local dirZ = endZ > startZ and 1 or -1;

    local curX = startX - dirX;
    local curY = startY;
    local curZ = startZ;

    return function()
        curX = curX + dirX;

        if curX - dirX == endX then
            curX = startX;
            curY = curY + dirY;
        end

        if curY - dirY == endY then
            curY = startY;
            curZ = curZ + dirZ;
        end

        if curZ - dirZ ~= endZ then
            return curX, curY, curZ;
        end
    end
end
function oOrderIterator(tbl, front)
    front = front or 1;
    local ind = -1;

    return function()
        ind = ind + 1;

        if ind == 0 then
            return front, tbl[front];
        end

        if ind >= #tbl then
            return;
        end

        if ind < front then
            return ind, tbl[ind];
        else
            return ind + 1, tbl[ind + 1];
        end
    end
end

--~ end of global stuffs :3


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

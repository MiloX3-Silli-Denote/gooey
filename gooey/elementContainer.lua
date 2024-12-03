local ElementContainer = {};

ElementContainer.__index = ElementContainer;

function ElementContainer.new(x, y, gridSize, _maxWidth, _maxheight)
    local instance = setmetatable({}, ElementContainer);

    instance.x = x or 0;
    instance.y = y or 0;

    if _maxWidth then
        instance.maxX = math.floor(_maxWidth / gridSize);
    end
    if _maxheight then
        instance.maxY = math.floor(_maxheight / gridSize);
    end

    instance.active = true;

    instance.gridSize = gridSize;

    instance.grid = {};
    instance.elements = {};

    instance.focus = nil;

    return instance;
end

function ElementContainer:at(x, y)
    x = math.floor((x - self.x) / self.gridSize);
    y = math.floor((y - self.y) / self.gridSize);

    if checkDeep(self.grid, x, y) then
        return self.elements[self.grid[x][y]];
    end
end

function ElementContainer:addElement(obj)
    table.insert(self.elements, obj);
end

function ElementContainer:claimAt(obj, x, y)
    x = math.floor((x - self.x) / self.gridSize);
    y = math.floor((y - self.y) / self.gridSize);

    if self.maxX and (x < 0 or x > self.maxX) then
        error("tried to claim out of bounds of a bounded element container");
        return;
    end
    if self.maxY and (y < 0 or y > self.maxY) then
        error("tried to claim out of bounds of a bounded element container");
        return;
    end

    local elID = nil;

    for i, v in ipairs(self.elements) do
        if v == obj then
            elID = i;
            break;
        end
    end

    if isNil(elID) then
        self:addElement(obj);

        elID = #self.elements;
    end

    if isNil(self.grid[x]) then
        self.grid[x] = {};
    end

    self.grid[x][y] = elID;
end
function ElementContainer:claimIn(obj, minX, minY, maxX, maxY)
    minX = math.floor((minX - self.x) / self.gridSize);
    maxX = math.floor((maxX - self.x) / self.gridSize);
    minY = math.floor((minY - self.y) / self.gridSize);
    maxY = math.floor((maxY - self.y) / self.gridSize);

    if minX > maxX then
        minX, maxX = maxX, minX;
    end
    if minY > maxY then
        minY, maxY = maxY, minY;
    end

    if self.maxX then
        if minX < 0 or maxX > self.maxX then
            error("tried to claim out of bounds of a bounded element container");
            return;
        end
    end
    if self.maxY then
        if minY < 0 or maxY > self.maxY then
            error("tried to claim out of bounds of a bounded element container");
            return;
        end
    end

    local elID = nil;

    for i, v in ipairs(self.elements) do
        if v == obj then
            elID = i;
            break;
        end
    end

    if isNil(elID) then
        self:addElement(obj);

        elID = #self.elements;
    end

    for x = minX, maxX do
        if isNil(self.grid[x]) then
            self.grid[x] = {};
        end

        for y = minY, maxY do
            self.grid[x][y] = elID;
        end
    end
end
function ElementContainer:unClaimAt(obj, x, y)
    x = math.floor((x - self.x) / self.gridSize);
    y = math.floor((y - self.y) / self.gridSize);

    local elID = nil;

    for i, v in ipairs(self.elements) do
        if v == obj then
            elID = i;
            break;
        end
    end

    if isNil(elID) then
        return;
    end

    if self.grid[x] and self.grid[x][y] == elID then
        self.grid[x][y] = nil;
    end
end
function ElementContainer:unClaimIn(obj, minX, minY, maxX, maxY)
    minX = math.floor((minX - self.x) / self.gridSize);
    maxX = math.floor((maxX - self.x) / self.gridSize);
    minY = math.floor((minY - self.y) / self.gridSize);
    maxY = math.floor((maxY - self.y) / self.gridSize);

    local elID = nil;

    for i, v in ipairs(self.elements) do
        if v == obj then
            elID = i;
            break;
        end
    end

    if isNil(elID) then
        return;
    end

    for x = minX, maxX do
        if self.grid[x] then
            for y = minY, maxY do
                if self.grid[x][y] == elID then
                    self.grid[x][y] = nil;
                end
            end
        end
    end
end

function ElementContainer:textinput(text)
    if not self.focus then
        return;
    end
    if not self.elements[self.focus] then
        return;
    end

    if self.elements[self.focus].textInput then
        self.elements[self.focus]:textInput(text);
    end
end
function ElementContainer:keypressed(key, _scancode_, isrepeat)
    if not self.focus then
        return;
    end
    if not self.elements[self.focus] then
        return;
    end

    if self.elements[self.focus].keyPressed then
        self.elements[self.focus]:keyPressed(key, isrepeat);
    end
end
function ElementContainer:keyreleased(key, _scancode_)
    if not self.focus then
        return;
    end
    if not self.elements[self.focus] then
        return;
    end

    if self.elements[self.focus].keyReleased then
        self.elements[self.focus]:keyReleased(key);
    end
end

function ElementContainer:mousemoved(x, y, _dx_, _dy_, _isTouch_)
    local cx = math.floor((x - self.x) / self.gridSize);
    local cy = math.floor((y - self.y) / self.gridSize);
    local px = math.floor((x - _dx_ - self.x) / self.gridSize);
    local py = math.floor((y - _dy_ - self.y) / self.gridSize);

    if checkDeep(self.grid, cx, cy) and self.grid[cx][cy] ~= self.focus and self.elements[self.grid[cx][cy]] then
        if self.elements[self.grid[cx][cy]].mouseMoved then
            self.elements[self.grid[cx][cy]]:mouseMoved(x, y);
        end
    end

    if (px ~= cx or py ~= cy) and checkDeep(self.grid, px, py) and self.grid[px][py] ~= self.focus and self.elements[self.grid[px][py]] then
        if self.elements[self.grid[px][py]].mouseMoved then
            self.elements[self.grid[px][py]]:mouseMoved(x, y);
        end
    end

    if not self.focus then
        return;
    end
    if not self.elements[self.focus] then
        return;
    end

    if self.elements[self.focus].mouseMoved then
        self.elements[self.focus]:mouseMoved(x, y);
    end
end
function ElementContainer:mousepressed(x, y, button, _isTouch_, presses)
    local cx = math.floor((x - self.x) / self.gridSize);
    local cy = math.floor((y - self.y) / self.gridSize);

    local curFocus = nil;

    if self.focus then
        curFocus = self.elements[self.focus];
    end

    if checkDeep(self.grid, cx, cy) then
        if self.grid[cx][cy] ~= self.focus then
            if curFocus and curFocus.loseFocus then
                curFocus:loseFocus();
            end

            self.focus = self.grid[cx][cy];

            if self.elements[self.focus] and self.elements[self.focus].gainFocus then
                self.elements[self.focus]:gainFocus();
            end
        end
    else
        if curFocus and curFocus.loseFocus then
            curFocus:loseFocus();
        end

        self.focus = nil;
    end

    if self.focus and self.elements[self.focus] and self.elements[self.focus].mousePressed then
        self.elements[self.focus]:mousePressed(x, y, button, presses);
    end
end
function ElementContainer:mousereleased(x, y, button, _isTouch_, presses)
    if not self.focus then
        return;
    end
    if not self.elements[self.focus] then
        return;
    end

    if self.elements[self.focus].mouseReleased then
        self.elements[self.focus]:mouseReleased(x, y, button, presses);
    end
end
function ElementContainer:wheelmoved(x, y)
    if not self.focus then
        return;
    end
    if not self.elements[self.focus] then
        return;
    end

    if self.elements[self.focus].wheelMoved then
        self.elements[self.focus]:wheelMoved(x, y);
    end
end

function ElementContainer:update(dt)
    for i, v in ipairs(self.elements) do
        if v.update then
            v:update(dt);
        end
    end
end
function ElementContainer:draw()
    for i, v in ipairs(self.elements) do
        if v.draw then
            v:draw();
        end
    end
end

return ElementContainer;
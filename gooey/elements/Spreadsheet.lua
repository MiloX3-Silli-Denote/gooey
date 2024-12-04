local Spreadsheet = {};

Spreadsheet.__index = Spreadsheet;

function Spreadsheet.new(x, y, w, h, cols, rows)
    assert(isNum(x, y, w, h), "bad arguments to create 'Spreadsheet'");

    local instance = setmetatable({}, Spreadsheet);

    instance.x = x;
    instance.y = y;
    instance.w = w;
    instance.h = h;

    instance.rows = rows;
    instance.cols = cols;
    instance.boxWidth = w / cols;
    instance.boxHeight = h / rows;

    instance.textBoxes = {};
    instance.locks = {};
    instance.focus = {};

    for X = 1, cols do
        instance.textBoxes[X] = {};
        instance.locks[X] = {};
        instance.focus[X] = {}

        for Y = 1, rows do
            instance.locks[X][Y] = false;
            instance.focus[X][Y] = false;
            instance.textBoxes[X][Y] = SimpleTextInput(
                x + (X - 1) * instance.boxWidth,
                y + (Y - 1) * instance.boxHeight,
                instance.boxWidth,
                instance.boxHeight
            );
        end
    end

    return instance;
end

function Spreadsheet:resetBlink()
    for x, y in squareIterator(1, 1, self.cols, self.rows) do
        self.textBoxes[x][y].blink = true;
        self.textBoxes[x][y].blinkTimer = 0.5;
    end
end

function Spreadsheet:loseFocus()
    for x, y in squareIterator(1, 1, self.cols, self.rows) do
        self.focux[x][y] = false;
    end
end

function Spreadsheet:textInput(text)
    for x, y in squareIterator(1, 1, self.cols, self.rows) do
        if not self.locks[x][y] and self.focus[x][y] then
            self.textBoxes[x][y]:textInput(text);
        end
    end
end
function Spreadsheet:keyPressed(key, isRepeat)
    if key == "backspace" then
        for x, y in squareIterator(1, 1, self.cols, self.rows) do
            if not self.locks[x][y] and self.focus[x][y] then
                self.textBoxes[x][y]:keyPressed(key, isRepeat);
            end
        end

        return;
    elseif key == "return" then
        for x, y in squareIterator(1, 1, self.cols, self.rows) do
            self.focus[x][y] = false;
        end

        return;
    end

    if key == "up" then
        local SHFT = love.keyboard.isDown("lshift");
        local CTRL = love.keyboard.isDown("lctrl");

        self:resetBlink();

        if SHFT and CTRL then
            for x, y in squareIterator(1, 2, self.cols, self.rows) do
                if self.focus[x][y] and not self.locks[x][y] then
                    local lastViable = y;
                    for ny = y - 1, 1, -1 do
                        if not self.focus[x][ny] and not self.locks[x][ny] then
                            lastViable = ny;
                        else
                            break;
                        end
                    end

                    for ny = lastViable, y do
                        self.focus[x][ny] = true;
                    end
                end
            end
        elseif SHFT then
            for x, y in squareIterator(1, 2, self.cols, self.rows) do
                if self.focus[x][y] and not self.locks[x][y] then
                    if not self.focus[x][y - 1] and not self.locks[x][y - 1] then
                        self.focus[x][y - 1] = true;
                    end
                end
            end
        elseif CTRL then
            for x, y in squareIterator(1, 2, self.cols, self.rows) do
                if self.focus[x][y] and not self.locks[x][y] then
                    local lastViable = y;
                    for ny = y - 1, 1, -1 do
                        if not self.focus[x][ny] and not self.locks[x][ny] then
                            lastViable = ny;
                        else
                            break;
                        end
                    end

                    self.focus[x][y] = false;
                    self.focus[x][lastViable] = true;
                end
            end
        else
            for x, y in squareIterator(1, 2, self.cols, self.rows) do
                if self.focus[x][y] and not self.locks[x][y] then
                    if not self.focus[x][y - 1] and not self.locks[x][y - 1] then
                        self.focus[x][y] = false;
                        self.focus[x][y - 1] = true;
                    end
                end
            end
        end
    elseif key == "right" then
        local SHFT = love.keyboard.isDown("lshift");
        local CTRL = love.keyboard.isDown("lctrl");

        self:resetBlink();

        if SHFT and CTRL then
            for y, x in squareIterator(1, self.cols - 1, self.rows, 1) do
                if self.focus[x][y] and not self.locks[x][y] then
                    local lastViable = x;
                    for nx = x + 1, self.cols do
                        if not self.focus[nx][y] and not self.locks[nx][y] then
                            lastViable = nx;
                        else
                            break;
                        end
                    end

                    for nx = x, lastViable do
                        self.focus[nx][y] = true;
                    end
                end
            end
        elseif SHFT then
            for y, x in squareIterator(1, self.cols - 1, self.rows, 1) do
                if self.focus[x][y] and not self.locks[x][y] then
                    if not self.focus[x + 1][y] and not self.locks[x + 1][y] then
                        self.focus[x + 1][y] = true;
                    end
                end
            end
        elseif CTRL then
            for y, x in squareIterator(1, self.cols - 1, self.rows, 1) do
                if self.focus[x][y] and not self.locks[x][y] then
                    local lastViable = x;
                    for nx = x + 1, self.cols do
                        if not self.focus[nx][y] and not self.locks[nx][y] then
                            lastViable = nx;
                        else
                            break;
                        end
                    end

                    self.focus[x][y] = false;
                    self.focus[lastViable][y] = true;
                end
            end
        else
            for y, x in squareIterator(1, self.cols - 1, self.rows, 1) do
                if self.focus[x][y] and not self.locks[x][y] then
                    if not self.focus[x + 1][y] and not self.locks[x + 1][y] then
                        self.focus[x][y] = false;
                        self.focus[x + 1][y] = true;
                    end
                end
            end
        end
    elseif key == "down" then
        local SHFT = love.keyboard.isDown("lshift");
        local CTRL = love.keyboard.isDown("lctrl");

        self:resetBlink();

        if SHFT and CTRL then
            for x, y in squareIterator(1, self.rows - 1, self.cols, 1) do
                if self.focus[x][y] and not self.locks[x][y] then
                    local lastViable = y;
                    for ny = y + 1, self.rows do
                        if not self.focus[x][ny] and not self.locks[x][ny] then
                            lastViable = ny;
                        else
                            break;
                        end
                    end

                    for ny = y, lastViable do
                        self.focus[x][ny] = true;
                    end
                end
            end
        elseif SHFT then
            for x, y in squareIterator(1, self.rows - 1, self.cols, 1) do
                if self.focus[x][y] and not self.locks[x][y] then
                    if not self.focus[x][y + 1] and not self.locks[x][y + 1] then
                        self.focus[x][y + 1] = true;
                    end
                end
            end
        elseif CTRL then
            for x, y in squareIterator(1, self.rows - 1, self.cols, 1) do
                if self.focus[x][y] and not self.locks[x][y] then
                    local lastViable = y;
                    for ny = y + 1, self.rows do
                        if not self.focus[x][ny] and not self.locks[x][ny] then
                            lastViable = ny;
                        else
                            break;
                        end
                    end

                    self.focus[x][y] = false;
                    self.focus[x][lastViable] = true;
                end
            end
        else
            for x, y in squareIterator(1, self.rows - 1, self.cols, 1) do
                if self.focus[x][y] and not self.locks[x][y] then
                    if not self.focus[x][y + 1] and not self.locks[x][y + 1] then
                        self.focus[x][y] = false;
                        self.focus[x][y + 1] = true;
                    end
                end
            end
        end
    elseif key == "left" then
        local SHFT = love.keyboard.isDown("lshift");
        local CTRL = love.keyboard.isDown("lctrl");

        self:resetBlink();

        if SHFT and CTRL then
            for y, x in squareIterator(1, 2, self.rows, self.cols) do
                if self.focus[x][y] and not self.locks[x][y] then
                    local lastViable = x;
                    for nx = x - 1, 1, -1 do
                        if not self.focus[nx][y] and not self.locks[nx][y] then
                            lastViable = nx;
                        else
                            break;
                        end
                    end

                    for nx = x, lastViable do
                        self.focus[nx][y] = true;
                    end
                end
            end
        elseif SHFT then
            for y, x in squareIterator(1, 2, self.rows, self.cols) do
                if self.focus[x][y] and not self.locks[x][y] then
                    if not self.focus[x - 1][y] and not self.locks[x - 1][y] then
                        self.focus[x - 1][y] = true;
                    end
                end
            end
        elseif CTRL then
            for y, x in squareIterator(1, 2, self.rows, self.cols) do
                if self.focus[x][y] and not self.locks[x][y] then
                    local lastViable = x;
                    for nx = x - 1, 1, -1 do
                        if not self.focus[nx][y] and not self.locks[nx][y] then
                            lastViable = nx;
                        else
                            break;
                        end
                    end

                    self.focus[x][y] = false;
                    self.focus[lastViable][y] = true;
                end
            end
        else
            for y, x in squareIterator(1, 2, self.rows, self.cols) do
                if self.focus[x][y] and not self.locks[x][y] then
                    if not self.focus[x - 1][y] and not self.locks[x - 1][y] then
                        self.focus[x][y] = false;
                        self.focus[x - 1][y] = true;
                    end
                end
            end
        end
    end
end

function Spreadsheet:mouseMoved(x, y)
    local boxOverX = math.floor((x - self.x) / self.boxWidth) + 1;
    local boxOverY = math.floor((y - self.y) / self.boxHeight) + 1;

    love.mouse.setCursor();

    if boxOverX < 1 then
        return;
    end
    if boxOverY < 1 then
        return;
    end
    if boxOverX > self.cols then
        return;
    end
    if boxOverY > self.rows then
        return;
    end

    if self.locks[boxOverX][boxOverY] then
        love.mouse.setCursor(love.mouse.getSystemCursor("no"));
    else
        love.mouse.setCursor(love.mouse.getSystemCursor("ibeam"));
    end
end
function Spreadsheet:mousePressed(x, y, button, presses)
    local boxOverX = math.floor((x - self.x) / self.boxWidth) + 1;
    local boxOverY = math.floor((y - self.y) / self.boxHeight) + 1;

    if boxOverX < 1 then
        return;
    end
    if boxOverY < 1 then
        return;
    end
    if boxOverX > self.cols then
        return;
    end
    if boxOverY > self.rows then
        return;
    end

    if not self.locks[boxOverX][boxOverY] then
        if love.keyboard.isDown("lshift") then
            if not self.locks[boxOverX][boxOverY] then
                self.focus[boxOverX][boxOverY] = true;

                self:resetBlink();
            end
        else
            self:resetBlink();

            for x, y in squareIterator(1, 1, self.cols, self.rows) do
                self.focus[x][y] = (not self.locks[x][y] and x == boxOverX and y == boxOverY);
            end
        end
    end
end

function Spreadsheet:update(dt)
    for x, y in squareIterator(1, 1, self.cols, self.rows) do
        self.textBoxes[x][y].active = self.focus[x][y];
        self.textBoxes[x][y]:update(dt);
    end
end
function Spreadsheet:draw()
    for x, y in squareIterator(1, 1, self.cols, self.rows) do
        self.textBoxes[x][y]:draw();
    end
end

return setmetatable({}, {__call = function(_, ...) return Spreadsheet.new(...) end});
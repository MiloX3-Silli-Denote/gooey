local ElementContainer = {};

ElementContainer.__index = ElementContainer;

function ElementContainer.new()
    local instance = setmetatable({}, ElementContainer);

    instance.active = true;
    instance.elements = {};
    instance.focus = nil;

    return instance;
end

function ElementContainer:addElement(obj)
    if not obj.x then
        error("cannot add component without: 'x', try using the component base to create a component");
    end
    if not obj.y then
        error("cannot add component without: 'y', try using the component base to create a component");
    end
    if not obj.w then
        error("cannot add component without: 'w', try using the component base to create a component");
    end
    if not obj.h then
        error("cannot add component without: 'h', try using the component base to create a component");
    end

    table.insert(self.elements, 1, obj);

    if self.focus then
        self.focus = self.focus + 1;
    end

    return obj;
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
    if self.focus and self.elements[self.focus] then
        local elem = self.elements[self.focus];

        if math.pointInRect(x, y, elem.x, elem.y, elem.w, elem.h) then
            if elem.mouseMoved then
                elem:mouseMoved(x, y);
            end

            return;
        elseif math.pointInRect(x - _dx_, y - _dy_, elem.x, elem.y, elem.w, elem.h) then
            if elem.mouseMoved then
                elem:mouseMoved(x, y);
            end

            return;
        end
    end

    for i, v in ipairs(self.elements) do
        if v.mouseMoved and i ~= self.focus and math.pointInRect(x, y, v.x, v.y, v.w, v.h) then
            for j, w in ipairs(self.elements) do
                if w.mouseMoved and j ~= self.focus and i ~= j and math.pointInRect(x - _dx_, y - _dy_, w.x, w.y, w.w, w.h) then
                    w:mouseMoved(x, y);

                    return;
                end
            end

            v:mouseMoved(x, y);

            return;
        end
    end

    for j, w in ipairs(self.elements) do
        if w.mouseMoved and j ~= self.focus and math.pointInRect(x - _dx_, y - _dy_, w.x, w.y, w.w, w.h) then
            w:mouseMoved(x, y);

            return;
        end
    end
end
function ElementContainer:mousepressed(x, y, button, _isTouch_, presses)
    if self.focus and self.elements[self.focus] then
        local elem = self.elements[self.focus];

        if math.pointInRect(x, y, elem.x, elem.y, elem.w, elem.h) then
            if elem.mousePressed then
                elem:mousePressed(x, y, button, presses);
            end

            return;
        else
            if elem.loseFocus then
                elem:loseFocus();
            end

            self.focus = nil;
        end
    end

    for i, v in ipairs(self.elements) do
        if i ~= self.focus then
            if math.pointInRect(x, y, v.x, v.y, v.w, v.h) then
                if v.gainFocus then
                    v:gainFocus();
                end

                self.focus = i;

                if v.mousePressed then
                    v:mousePressed(x, y, button, presses);
                end

                return;
            end
        end
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
    for i = #self.elements, 1, -1 do
        if self.elements[i].draw and self.focus ~= i then
            self.elements[i]:draw();
        end
    end

    if not self.focus then
        return;
    end
    if not self.elements[self.focus] then
        return;
    end

    if self.elements[self.focus].draw then
        self.elements[self.focus]:draw();
    end
end

return ElementContainer;

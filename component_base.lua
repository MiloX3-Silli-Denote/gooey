-- replace all uses of 'ELEMENT_NAME' with the name of the element you are creating

local ELEMENT_NAME = {};

ELEMENT_NAME.__index = ELEMENT_NAME;

function ELEMENT_NAME.new(container, x, y, w, h) -- add as many additional arguments as you want
  assert(isNum(x, y, w, h), "bad arguments to create 'ELEMENT_NAME'");

	local instance = setmetatable({}, ELEMENT_NAME);

	instance.x = x;
	instance.y = y;
	instance.w = w;
	instance.h = h;

  -- set key of instance of however many inputs you need

	return instance;
end

function ELEMENT_NAME:gainFocus() -- called when this element gets clicked nearby
end
function ELEMENT_NAME:loseFocus() -- called when this element had focus (from above function) but was clicked off of
end

function ELEMENT_NAME:textInput(text)
end
function ELEMENT_NAME:keyPressed(key, isRepeat)
end
function ELEMENT_NAME:keyReleased(key)
end

function ELEMENT_NAME:mouseMoved(x, y)
end
function ELEMENT_NAME:mousePressed(x, y, button, presses)
end
function ELEMENT_NAME:mouseReleased(x, y, button, presses)
end
function ELEMENT_NAME:wheelMoved(x, y)
end

function ELEMENT_NAME:update(dt)
end
function ELEMENT_NAME:draw()
end

return setmetatable({}, {__call = function(_, ...) return ELEMENT_NAME.new(...) end});

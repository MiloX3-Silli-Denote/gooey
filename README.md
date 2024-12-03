# Gooey
GUI library for love2d that has some premade components (like buttons and toggles and text boxes) but allows for easily making new custom components

## Usage
download the gooey folder and place it into your project (license is in folder aswell)
place ```Gooey = require("gooey/gooey");``` in your main script
and update gooey's event functions on the events:
```lua
Gooey = require("gooey/gooey");

function love.textinput(text)
    Gooey:textinput(text);
end
function love.keypressed(key, scancode, isrepeat)
    Gooey:keypressed(key, scancode, isrepeat);
end
function love.keyreleased(key, scancode)
    Gooey:keyreleased(key, scancode);
end

function love.mousemoved(x, y, dx, dy, isTouch)
    Gooey:mousemoved(x, y, dx, dy, isTouch);
end
function love.mousepressed(x, y, button, isTouch, presses)
    Gooey:mousepressed(x, y, button, isTouch, presses);
end
function love.mousereleased(x, y, button, isTouch, presses)
    Gooey:mousereleased(x, y, button, isTouch, presses);
end
function love.wheelmoved(x, y)
    Gooey:wheelmoved(x, y);
end

function love.update(dt)
    Gooey:update(dt);
end
function love.draw()
    Gooey:draw();
end
```
### Basic Usage
to create a new gui scene you call ```Gooey:newContainer(x, y, gridSize, [max_w, max_h]);``` which returns a new container.
containers act as a grid of tiles (gridSize is the amount of pixels of width each tile has) and each tile can have one gui element assigned to it.
whenever a tile is interacted with, like hovering over it or clicking on it, its assigned element gets the associated event called.
non-position based events (like key presses) are only called on the 'focus' element, an element becomes the 'focus' element when a tile assigned to it is clicked on.

To add a new element onto a gui container you must call the element as a function with the container as the first argument.
```lua
local newButton = Button(container, x, y, w, h, callbackFunc);
```

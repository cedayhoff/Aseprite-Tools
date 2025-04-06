--[[
  Isometric Grid Generator for Aseprite
  Provided "AS IS", without warranty of any kind.
  No license granted or implied.
  Created by @cedayhoff
]]

local spr = app.activeSprite
if not spr then return app.alert("No active sprite") end

local layer = app.activeLayer
if not layer then return app.alert("No active layer") end

local frame = app.activeFrame
local cel = layer:cel(frame)

local imgW = spr.width
local imgH = spr.height

-- Default values
local defaults = {
  tileW = 64,
  tileH = 32,
  color = Color{ r=0, g=0, b=0 },
  preset = "2:1 Isometric"
}

-- Dialog
local dlg = Dialog("Isometric Grid Options")
dlg:slider{ id="tileW", label="Tile Width", min=8, max=128, value=defaults.tileW }
dlg:slider{ id="tileH", label="Tile Height", min=8, max=128, value=defaults.tileH }
dlg:color { id="color", label="Line Color", color=defaults.color }
dlg:combobox{
  id="preset",
  label="Preset",
  options={ "2:1 Isometric", "3:2 Shallow", "1:1 Diamond" },
  option=defaults.preset
}
dlg:button{ id="ok", text="Draw Grid" }
dlg:show()

local data = dlg.data
if not data.ok then return end

-- Apply preset if selected
if data.preset == "2:1 Isometric" then
  data.tileW = 64
  data.tileH = 32
elseif data.preset == "3:2 Shallow" then
  data.tileW = 48
  data.tileH = 32
elseif data.preset == "1:1 Diamond" then
  data.tileW = 32
  data.tileH = 32
end

local img = Image(imgW, imgH, spr.colorMode)

function drawLine(img, x0, y0, x1, y1, color)
  local dx = math.abs(x1 - x0)
  local dy = -math.abs(y1 - y0)
  local sx = x0 < x1 and 1 or -1
  local sy = y0 < y1 and 1 or -1
  local err = dx + dy

  while true do
    if x0 >= 0 and x0 < img.width and y0 >= 0 and y0 < img.height then
      img:putPixel(x0, y0, color)
    end
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy; x0 = x0 + sx end
    if e2 <= dx then err = err + dx; y0 = y0 + sy end
  end
end

local tileW = data.tileW
local tileH = data.tileH
local color = data.color

local slope = tileH / tileW
local maxY = math.max(imgH, imgW)
local numLines = math.ceil(maxY / tileH) * 2

for y = -numLines, numLines do
  local x0 = 0
  local y0 = y * tileH
  local x1 = imgW
  drawLine(img, x0, y0, x1, y0 + imgW / slope, color)
  drawLine(img, x0, y0, x1, y0 - imgW / slope, color)
end

if not cel then
  spr:newCel(layer, frame, img, Point(0, 0))
else
  cel.image = img
end

app.refresh()

--[[ Copyright (c) 2010 Manuel "Roujin" Wolf

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. --]]

--! Load Map Window
class "UILoadMap" (UIFileBrowser)

---@type UILoadMap
local UILoadMap = _G["UILoadMap"]

function UILoadMap:UILoadMap(ui, mode)
  local path = ui.app.user_level_dir
  local treenode = FilteredFileTreeNode(path, ".map")
  treenode.label = "Maps"
  self:UIFileBrowser(ui, mode, _S.load_map_window.caption:format(".map"), 295,
      treenode, true, _S.load_game_window.load_button)
  -- The most probable preference of sorting is by date - what you played last
  -- is the thing you want to play soon again.
  self.control:sortByDate()
end

function UILoadMap:choiceMade(name)
  local app = self.ui.app
  -- Make sure there is no blue filter active.
  app.video:setBlueFilterActive(false)
  app:loadLevel(name, nil, nil, nil, nil, true, _S.errors.load_map_prefix, nil)
end

function UILoadMap:close()
  UIResizable.close(self)
  if self.mode == "menu" then
    self.ui:addWindow(UIMainMenu(self.ui))
  end
end

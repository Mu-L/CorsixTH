--[[ Copyright (c) 2009 Peter "Corsix" Cawley

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

class "PickupAction" (HumanoidAction)

---@type PickupAction
local PickupAction = _G["PickupAction"]

-- Construct a pick-up action
--!param ui User interface
function PickupAction:PickupAction(ui)
  assert(class.is(ui, UI), "Invalid value for parameter 'ui'")

  self:HumanoidAction("pickup")
  self.ui = ui
  self.todo_close = nil
  self:setMustHappen(true)
end

function PickupAction:setTodoClose(dialog)
  assert(class.is(dialog, Window), "Invalid value for parameter 'dialog'")

  self.todo_close = dialog
  return self
end

local action_pickup_interrupt = permanent"action_pickup_interrupt"( function(action, humanoid)
  if action.window then
    action.window:close()
  end
  humanoid.th:makeVisible()
  local room = humanoid:getRoom()
  if room and room.crashed then
    action.ui:setDefaultCursor(nil)
    return
  elseif room then
    room:onHumanoidEnter(humanoid)
  else
    humanoid:onPlaceInCorridor()
  end
  humanoid:finishAction()
  action.ui:setDefaultCursor(nil)
end)

local action_pickup_dont_interrupt = permanent"action_pickup_dont_interrupt"( function(action)
  action.on_interrupt = action_pickup_interrupt
end)

local function action_pickup_start(action, humanoid)
  humanoid.dealing_with_patient = nil
  if action.todo_close then
    action.todo_close:close()
  end
  if class.is(humanoid, Staff) then
    humanoid:onPickup()
  end
  humanoid:setSpeed(0, 0)
  humanoid.th:makeInvisible()
  local room = humanoid:getRoom()
  if room then
    room:onHumanoidLeave(humanoid)
  end
  action.must_happen = true
  if action.todo_interrupt and action.todo_interrupt ~= "high" then
    -- If you pick up a staff member as they walk through a door, then the walk
    -- action will be given a high priority interrupt, and hence immediately
    -- dump the staff member in the room, at which point the room will command
    -- the entering staff, sending this pick up action a normal interrupt. We
    -- will completely ignore that, as the user's wish to pick up the staff is
    -- more important than the room's wish to command the staff.
    -- action_pickup_dont_interrupt will then set the interrupt handler back to
    -- normal, as that is called when the staff member is placed down again.
    action.on_interrupt = action_pickup_dont_interrupt
  else
    action.on_interrupt = action_pickup_interrupt
  end
  local ui = action.ui
  action.window = UIPlaceStaff(ui, humanoid, ui.cursor_x, ui.cursor_y)
  ui:addWindow(action.window)
  ui:playSound("pickup.wav")
  ui:setDefaultCursor(ui.grab_cursor)
end

return action_pickup_start

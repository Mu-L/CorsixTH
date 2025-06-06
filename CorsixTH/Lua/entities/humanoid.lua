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

--! An `Entity` which occupies a single tile and is capable of moving around the map.
class "Humanoid" (Entity)

---@type Humanoid
local Humanoid = _G["Humanoid"]

local walk_animations = permanent"humanoid_walk_animations"({})
local door_animations = permanent"humanoid_door_animations"({})
local die_animations = permanent"humanoid_die_animations"({})
local falling_animations = permanent"humanoid_falling_animations"({})
local on_ground_animations = permanent"humanoid_on_ground_animations"({})
local get_up_animations = permanent"humanoid_get_up_animations"({})
local shake_fist_animations = permanent"humanoid_shake_fist_animations"({})
local pee_animations = permanent"humanoid_pee_animations"({})
local vomit_animations = permanent"humanoid_vomit_animations"({})
local tap_foot_animations = permanent"humanoid_tap_foot_animations"({})
local yawn_animations = permanent"humanoid_yawn_animations"({})
local check_watch_animations = permanent"humanoid_check_watch_animations"({})

local mood_icons = permanent"humanoid_mood_icons"({})

local function walk_anims(name, walkN, walkE, idleN, idleE, doorL, doorE, knockN, knockE, swingL, swingE)
  walk_animations[name] = {
    walk_east = walkE,
    walk_north = walkN,
    idle_east = idleE,
    idle_north = idleN,
  }
  door_animations[name] = {
    entering = doorE,
    leaving = doorL,
    entering_swing = swingE,
    leaving_swing = swingL,
    knock_north = knockN,
    knock_east = knockE,
  }
end

---
-- @param name The name of the patient class these death animations are for.
-- @param fall The patient's fall animation.
-- @param rise The transparent getting up animation for heaven death patients who have been lying dead on the ground.
-- @param rise_hell The opaque getting up animation for hell death patients who have been lying dead on the ground.
-- @param wings The heaven death animation in which the patient's wings appear.
-- @param hands The heaven death animation which occurs after the wings animation when the patient puts their hands together.
-- @param fly The heaven death animation which makes patients fly upwards to heaven.
-- @param extra Dead untreated patients who don't transform before falling over use this animation afterwards to transform into a standard male/female.
---
local function die_anims(name, fall, rise, rise_hell, wings, hands, fly, extra)
  die_animations[name] = {
    fall_east = fall,
    rise_east = rise,
    rise_hell_east = rise_hell,
    wings_east = wings,
    hands_east = hands,
    fly_east = fly,
    extra_east = extra,
  }
end
local function falling_anim(name, fallingAnim)
  falling_animations[name] = fallingAnim
end
local function on_ground_anim(name, on_groundAnim)
  on_ground_animations[name] = on_groundAnim
end
local function get_up_anim(name, get_upAnim)
  get_up_animations[name] = get_upAnim
end
local function shake_fist_anim(name, shake_fistAnim)
  shake_fist_animations[name] = shake_fistAnim
end
local function vomit_anim(name, vomitAnim)
  vomit_animations[name] = vomitAnim
end
local function yawn_anim(name, yawnAnim)
  yawn_animations[name] = yawnAnim
end
local function tap_foot_anim(name, tap_footAnim)
  tap_foot_animations[name] = tap_footAnim
end
local function check_watch_anim(name, check_watchAnim)
  check_watch_animations[name] = check_watchAnim
end
local function pee_anim(name, peeAnim)
  pee_animations[name] = peeAnim
end
local function moods(name, iconNo, prio, onHover)
  mood_icons[name] = {icon = iconNo, priority = prio, on_hover = onHover}
end

--! Filter animations for patients and set the give marker positions.
local function assignPatientMarkers(anims, name, ...)
  local anim_mgr = TheApp.animation_manager

  for hum_type, anim in pairs(anims) do
    if string.find(hum_type, "Patient") then
      if name then anim = anim[name] end
      anim_mgr:setPatientMarker(anim, ...)
    end
  end
end

--! Filter animations for staff and set the give marker positions.
local function assignStaffMarkers(anims, name, ...)
  local anim_mgr = TheApp.animation_manager

  for hum_type, anim in pairs(anims) do
    if not string.find(hum_type, "Patient") then
      if name then anim = anim[name] end
      anim_mgr:setStaffMarker(anim, ...)
    end
  end
end


--   | Walk animations                 |
--   | Name                            |WalkN|WalkE|IdleN|IdleE|DoorL|DoorE|KnockN|KnockE|SwingL|SwingE| Notes
-----+---------------------------------------+-----+-----+-----+-----+-----+-----+------+------+-------+---------+
walk_anims("Standard Male Patient",       16,   18,   24,   26,  182,  184,   286,   288,  2040,  2042) -- 0-16, ABC
walk_anims("Gowned Male Patient",        406,  408,  414,  416)                           -- 0-10
walk_anims("Stripped Male Patient",      818,  820,  826,  828)                           -- 0-16
walk_anims("Stripped Male Patient 2",    818,  820,  826,  828)                           -- 0-16
walk_anims("Stripped Male Patient 3",    818,  820,  826,  828)
walk_anims("Alternate Male Patient",    2704, 2706, 2712, 2714, 2748, 2750,  2764,  2766) -- 0-10, ABC
walk_anims("Slack Male Patient",        1484, 1486, 1492, 1494, 1524, 1526,  2764,  1494) -- 0-14, ABC
walk_anims("Slack Female Patient",         0,    2,    8,   10,  258,  260,   294,   296,  2864,  2866) -- 0-16, ABC
walk_anims("Transparent Male Patient",  1064, 1066, 1072, 1074, 1104, 1106,  1120,  1074) -- 0-16, ABC
walk_anims("Standard Female Patient",      0,    2,    8,   10,  258,  260,   294,   296,  2864,  2866) -- 0-16, ABC
walk_anims("Gowned Female Patient",     2876, 2878, 2884, 2886)                           -- 0-8
walk_anims("Stripped Female Patient",    834,  836,  842,  844)                           -- 0-16
walk_anims("Stripped Female Patient 2",  834,  836,  842,  844)                           -- 0-16
walk_anims("Stripped Female Patient 3",  834,  836,  842,  844)
walk_anims("Transparent Female Patient",3012, 3014, 3020, 3022, 3052, 3054,  3068,  3070) -- 0-8, ABC
walk_anims("Chewbacca Patient",          858,  860,  866,  868, 3526, 3528,  4150,  4152)
walk_anims("Elvis Patient",              978,  980,  986,  988, 3634, 3636,  4868,  4870)
walk_anims("Invisible Patient",         1642, 1644, 1840, 1842, 1796, 1798,  4192,  4194)
walk_anims("Alien Male Patient",        3598, 3600, 3606, 3608,  182,  184,   286,   288, 3626,  3628) -- remember, no "normal"-doors animation
walk_anims("Alien Female Patient",      3598, 3600, 3606, 3608,  258,  260,   294,   296, 3626,  3628) -- identical to male; however death animations differ
walk_anims("Doctor",                      32,   34,   40,   42,  670,  672,   nil,   nil, 4750,  4752)
walk_anims("Surgeon",                   2288, 2290, 2296, 2298)
walk_anims("Nurse",                     1206, 1208, 1650, 1652, 3264, 3266,   nil,   nil, 3272,  3274)
walk_anims("Handyman",                  1858, 1860, 1866, 1868, 3286, 3288,   nil,   nil, 3518,  3520)
walk_anims("Receptionist",              3668, 3670, 3676, 3678) -- Could do with door animations
walk_anims("VIP",                        266,  268,  274,  276)
walk_anims("Inspector",                  266,  268,  274,  276)
walk_anims("Grim Reaper",                994,  996, 1002, 1004)


local kfp1, kfp2, kfp3, kfp4, kfp5, kfp6, kfp7, kfp8
kfp1, kfp2, kfp3, kfp4 = {-19, -15, "px"}, {-26, -17, "px"}, {-26, -15, "px"}, {-22, -13, "px"}
kfp5, kfp6, kfp7, kfp8 = {-19, -9, "px"}, {-13, -5, "px"}, {-8, -4, "px"}, {-5, 0, "px"}
local doorE_markers = { -- Anim 3288 in particular
  kfp1, kfp2, kfp2, kfp2, kfp3, kfp4, kfp5, kfp6, kfp7, kfp8,
}

local kfp9, kfp10
kfp1, kfp2, kfp3, kfp4, kfp5 = {-7, 0, "px"}, {-14, 6, "px"}, {-12, 5, "px"}, {-11, 5, "px"}, {-7, 3, "px"}
kfp6, kfp7, kfp8, kfp9, kfp10 = {-4, 0, "px"}, {2, -1, "px"}, {10, -3, "px"}, {14, -7, "px"}, {20, -11, "px"}
local doorL_markers = { -- Anim 3286 in particular.
  kfp1, kfp2, kfp2, kfp3, kfp4, kfp5, kfp6, kfp7, kfp7, kfp8, kfp9, kfp10,
}

assignPatientMarkers(door_animations, "entering", doorE_markers)
assignPatientMarkers(door_animations, "leaving", doorL_markers)
assignPatientMarkers(door_animations, "leaving_swing", {3, 4, "px"}, {32, -14, "px"})
assignPatientMarkers(door_animations, "entering_swing", {-32, -10, "px"}, {0, -2, "px"})

assignStaffMarkers(door_animations, "entering", doorE_markers)
assignStaffMarkers(door_animations, "leaving", doorL_markers)
assignStaffMarkers(door_animations, "leaving_swing", {3, 4, "px"}, {32, -14, "px"})
assignStaffMarkers(door_animations, "entering_swing", {-32, -10, "px"}, {0, -2, "px"})

--  | Die Animations                 |
--  | Name                           |FallE|RiseE|RiseE Hell|WingsE|HandsE|FlyE|ExtraE| Notes 2248
----+--------------------------------+-----+-----+----------+-----+------+-----+------
die_anims("Standard Male Patient",     1682, 2434,       384, 2438,  2446, 2450) -- Always facing east or south
die_anims("Alternate Male Patient",    1682, 2434,      3404, 2438,  2446, 2450)
die_anims("Slack Male Patient",        1682, 2434,       384, 2438,  2446, 2450)
-- TODO: Where is slack male transformation? Uses alternate male for now.
die_anims("Transparent Male Patient",  4412, 2434,       384, 2438,  2446, 2450,  4416) -- Extra = Transformation
die_anims("Standard Female Patient",   3116, 3208,       580, 3212,  3216, 3220)
die_anims("Slack Female Patient",      4288, 3208,       580, 3212,  3216, 3220)
die_anims("Transparent Female Patient",4420, 3208,       580, 3212,  3216, 3220,  4428) -- Extra = Transformation
die_anims("Chewbacca Patient",         4182, 2434,       384, 2438,  2446, 2450,  1682) -- Only males die... (1222 is the Female)
die_anims("Elvis Patient",              974, 2434,       384, 2438,  2446, 2450,  4186) -- Extra = Transformation
die_anims("Invisible Patient",         4200, 2434,       384, 2438,  2446, 2450)
die_anims("Alien Male Patient",        4882, 2434,       384, 2438,  2446, 2450)
die_anims("Alien Female Patient",      4886, 3208,       580, 3212,  3216, 3220)

-- The next fours sets belong together, but are done like this so we can use them on their own
-- I also had difficulty in keeping them together, as the patient needs to be on the floor
-- for the duration of the earth quake before getting back up
-- Shaking of fist could perhaps be used when waiting too long

--  | Falling Animations                   |
--  | Name                                 |Anim| Notes
----+--------------------------------+-----+-----+-----+-----+------+------+
falling_anim("Standard Male Patient",     1682)
falling_anim("Standard Female Patient",   3116)

--  | On_ground Animations                   |
--  | Name                                 |Anim| Notes
----+--------------------------------+-----+-----+-----+-----+------+------+
on_ground_anim("Standard Male Patient",   1258)
on_ground_anim("Standard Female Patient", 1764)

--  | Get_up Animations                   |
--  | Name                                 |Anim| Notes
----+--------------------------------+-----+-----+-----+-----+------+------+
get_up_anim("Standard Male Patient",     384)
get_up_anim("Standard Female Patient",   580)

--  | Shake_fist Animations                   |
--  | Name                                 |Anim| Notes
----+--------------------------------+-----+-----+-----+-----+------+------+
shake_fist_anim("Standard Male Patient",   392) -- bloaty head patients lose head!

assignPatientMarkers(shake_fist_animations, nil, {0.0, 0.0})

--  | Vomit Animations                  |
--  | Name                              |Anim | Notes
----+-----------------------------------+-----+
vomit_anim("Elvis Patient",              1034)
vomit_anim("Standard Female Patient",    3184)
vomit_anim("Standard Male Patient",      2056)
vomit_anim("Alternate Male Patient",     4476)
vomit_anim("Chewbacca Patient",          4138)
vomit_anim("Invisible Patient",          4204)
vomit_anim("Slack Male Patient",         4324)
vomit_anim("Transparent Female Patient", 4452)
vomit_anim("Transparent Male Patient",   4384)

assignPatientMarkers(vomit_animations, nil, {0.0, 0.0})

--  | Yawn Animations                  |
--  | Name                              |Anim | Notes
----+-----------------------------------+-----+
yawn_anim("Standard Female Patient",    4864)
yawn_anim("Standard Male Patient",      368)
--yawn_anim("Alternate Male Patient",     2968)  is this one the same as standard male?
-- whichever one is used for male, if he wears a hat it will lift when he yawns

assignPatientMarkers(yawn_animations, nil, {0.0, 0.0})

--  | Foot tapping Animations                  |
--  | Name                              |Anim | Notes
----+-----------------------------------+-----+
tap_foot_anim("Standard Female Patient",    4464)
tap_foot_anim("Standard Male Patient",      2960)
tap_foot_anim("Alternate Male Patient",     360)

assignPatientMarkers(tap_foot_animations, nil, {0.0, 0.0})

--  | Check watch Animations                  |
--  | Name                              |Anim | Notes
----+-----------------------------------+-----+
check_watch_anim("Standard Female Patient",    4468)
check_watch_anim("Standard Male Patient",      2964)
check_watch_anim("Alternate Male Patient",     364)
check_watch_anim("Slack Male Patient",         4060)

assignPatientMarkers(check_watch_animations, nil, {0.0, 0.0})

--  | pee Animations                  |
--  | Name                              |Anim | Notes
----+-----------------------------------+-----+
pee_anim("Elvis Patient",              970)
pee_anim("Standard Female Patient",    4744)
pee_anim("Slack Female Patient",       4744)
pee_anim("Standard Male Patient",      2244)
pee_anim("Alternate Male Patient",     4472)
pee_anim("Slack Male Patient",         4328)
pee_anim("Chewbacca Patient",          4178)
pee_anim("Invisible Patient",          4208)
pee_anim("Transparent Female Patient", 4852)
pee_anim("Transparent Male Patient",   4848)

assignPatientMarkers(pee_animations, nil, {0.0, 0.0})

-- Some icons should only appear when the player hovers over the humanoid
-- Higher priority is more important.
--   | Available Moods |
--   | Name            |Icon|Priority|On Hover| Notes
-----+-----------------+----+--------+-----------+
moods("reflexion",      4020,       5)
moods("cantfind",       4050,       3)
moods("idea1",          2464,      10)
moods("idea2",          2466,      11)
moods("idea3",          4044,      12)
moods("staff_wait",     4054,      20)
moods("tired",          3990,      30)
moods("pay_rise",       4576,      40)
moods("thirsty",        3986,       4)
moods("cold",           3994,       0,   true) -- These have no priority since
moods("hot",            3988,       0,   true) -- they will be shown when hovering
                                               -- no matter what other priorities.
moods("queue",          4568,      70)
moods("poo",            3996,       5)
moods("sad_money",      4018,      55)
moods("patient_wait",   5006,      39)
moods("epidemy1",       4566,      55)
moods("epidemy2",       4570,      55)
moods("epidemy3",       4572,      55)
moods("epidemy4",       4574,      55)
moods("sad1",           3992,      39)          -- unused?
moods("sad2",           4578,      40)
moods("dying1",         4000,      41)
moods("dying2",         4002,      42)
moods("dying3",         4004,      43)
moods("dying4",         4006,      44)
moods("dying5",         4008,      45)
moods("dead",           4046,      60)
moods("cured",          4048,      60)
moods("emergency",      3914,      50)
moods("exit",           4052,      60)


--!param ... Arguments for base class constructor.
function Humanoid:Humanoid(...)
  self:Entity(...)
  self.action_queue = {}
  self.last_move_direction = "east"
  self.attributes = {}
  self.attributes["warmth"] = 0.29
  self.attributes["happiness"] = 1
  -- patients should be not be fully well when they come to your hospital and if it is staff there is no harm done!
  self.attributes["health"] = math.random(80, 100) /100
  self.active_moods = {}
  self.should_knock_on_doors = false

  self.speed = "normal"

  self.build_callbacks  = {--[[set]]}
  self.remove_callbacks = {--[[set]]}
  self.staff_change_callbacks = {--[[set]]}
end

-- Save game compatibility
function Humanoid:afterLoad(old, new)
  if old < 38 and new >= 38 then
    -- should existing patients be updated and be getting really ill?
    -- adds the new variables for health icons
    self.attributes["health"] = math.random(60, 100) /100
  end
  -- make sure female slack patients have the correct animation
  if old < 42 and new >= 42 then
    if self.humanoid_class == "Slack Female Patient" then
      self.die_anims = die_animations["Slack Female Patient"]
    end
  end
  if old < 77 and new >= 77 then
    self.has_vomitted = 0
  end
  if old < 49 and new >= 49 then
    self.has_fallen = 1
  end
  if old < 61 and new >= 61 then
    -- callbacks changed
    self.build_callbacks = {}
    self.remove_callbacks = {}
    if self.build_callback then
      self.build_callbacks[self.build_callback] = true
      self.build_callback = nil
    end
    if self.toilet_callback then
      self.build_callbacks[self.toilet_callback] = true
      self.toilet_callback = nil
    end
  end
  if old < 83 and new >= 83 and self.humanoid_class == "Chewbacca Patient" then
    self.die_anims.extra_east = 1682
  end
  if old < 134 and new >= 134 then
    self.staff_change_callbacks = {}
  end
  if old < 210 then
    -- We renamed the old sad7 to sad2; and sad2 - sad6 to dying1 - dying5.
    -- Make sure we adjust sad2 and sad7 to the new mood names
    -- Other dying ones aren't an issue
    if self:isMoodActive("sad2") then
      self:setMood("sad2", "deactivate")
      self:setMood("dying1", "activate")
    end
    if self:isMoodActive("sad7") then
      self:setMood("sad7", "deactivate")
      self:setMood("sad2", "activate")
    end
  end

  for _, action in pairs(self.action_queue) do
    -- Sometimes actions not actual instances of HumanoidAction
    HumanoidAction.afterLoad(action, old, new)
  end

  Entity.afterLoad(self, old, new)
end

-- Function which is called when the user clicks on the `Humanoid`.
--!param ui (GameUI) The UI which the user in question is using.
--!param button (string) One of: "left", "middle", "right".
function Humanoid:onClick(ui, button)
  if TheApp.config.debug then
    self:dump()
  end
end

function Humanoid:getRoom()
  return self.in_room or Entity.getRoom(self)
end

function Humanoid:dump()
  print("-----------------------------------")
  print("Clicked on: ")
  print(self:tostring())
  print("-----------------------------------")
end

-- Called when the humanoid is about to be removed from the world.
function Humanoid:onDestroy()
  local x, y = self.tile_x, self.tile_y
  if x and y then
    local notify_object = self.world:getObjectToNotifyOfOccupants(x, y)
    if notify_object then
      notify_object:onOccupantChange(-1)
    end
  end
  -- Make absolutely sure there are no callbacks left on the humanoid.
  self:unregisterCallbacks()
  return Entity.onDestroy(self)
end

-- Set the `Hospital` which is responsible for treating or employing the
-- `Humanoid`. In single player games, this has little effect, but it is very
-- important in multiplayer games.
--!param hospital (Hospital) The `Hospital` which should be responsible
-- for the `Humanoid`.
function Humanoid:setHospital(hospital)
  self.hospital = hospital
  if not hospital.is_in_world then
    self:despawn()
  end
end

--! Despawn the humanoid.
function Humanoid:despawn()
  local spawn_point = self.world.spawn_points[math.random(1, #self.world.spawn_points)]
  self:setNextAction(SpawnAction("despawn", spawn_point):setMustHappen(true))
end

-- Function to activate/deactivate moods of a humanoid.
-- If mood_name is nil it is considered a refresh only.
function Humanoid:setMood(mood_name, activate)
  if mood_name then
    if activate and activate ~= "deactivate" then
      if self.active_moods[mood_name] then
        return -- No use doing anything if it already exists.
      end
      self.active_moods[mood_name] = mood_icons[mood_name]
    else
      if not self.active_moods[mood_name] then
        return -- No use doing anything if the mood isn't there anyway.
      end
      self.active_moods[mood_name] = nil
    end
  end
  local new_mood = nil
  -- TODO: Make equal priorities cycle, or make all moods unique
  for _, value in pairs(self.active_moods) do
    if new_mood then -- There is a mood, check priorities.
      if new_mood.priority < value.priority then
        new_mood = value
      end
    else
      if not value.on_hover then
        new_mood = value
      end
    end
  end
  self:setMoodInfo(new_mood)
end

function Humanoid:setCallCompleted()
  if self.on_call then
    CallsDispatcher.onCheckpointCompleted(self.on_call)
  end
end

-- Is the given mood in the list of active moods.
function Humanoid:isMoodActive(mood)
  for i, _ in pairs(self.active_moods) do
    if i == mood then
      return true
    end
  end
  return false
end

function Humanoid.getIdleAnimation(humanoid_class)
  return assert(walk_animations[humanoid_class], "Invalid humanoid class").idle_east
end

function Humanoid:getCurrentMood()
  if self.mood_info then
    return self.mood_info
  end
end

--! Start the next (always first) action in the queue.
function Humanoid:startAction()
  local action = self.action_queue[1]

  -- Handle an empty action queue in some way instead of crashing.
  if not action then
    self:_handleEmptyActionQueue() -- Inserts an action into the action queue.

    action = self.action_queue[1]
    assert(action)
  end

  -- Call the action start handler
  TheApp.humanoid_actions[action.name](action, self)

  -- If action has been marked as to be interrupted
  if action == self.action_queue[1] and action.todo_interrupt and not action.uninterruptible then
    -- Interrupt this action
    local high_priority = action.todo_interrupt == "high"
    action.todo_interrupt = nil
    local on_interrupt = action.on_interrupt
    if on_interrupt then
      action.on_interrupt = nil
      on_interrupt(action, self, high_priority)
    end
  end
end

function Humanoid:setNextAction(action, high_priority)
  -- Aim: Cleanly finish the current action (along with any subsequent actions
  -- which must happen), then replace all the remaining actions with the given
  -- one.
  local i = 1
  local queue = self.action_queue
  local interrupted = false

  -- Skip over any actions which must happen
  while queue[i] and queue[i].must_happen do
    interrupted = true
    i = i + 1
  end

  -- Remove actions which are no longer going to happen
  local done_set = {}
  for j = #queue, i, -1 do
    local removed = queue[j]
    queue[j] = nil
    if not removed then
      -- A bug (rare) that removed could be nil.
      --   but as it's being removed anyway...it could be ignored
      print("Warning: Action to be removed was nil")
    else
      if removed.on_remove then
        removed.on_remove(removed, self)
      end
      if removed.until_leave_queue and not done_set[removed.until_leave_queue] then
        removed.until_leave_queue:removeValue(self)
        done_set[removed.until_leave_queue] = true
      end
      if removed.object and removed.object:isReservedFor(self) then
        removed.object:removeReservedUser(self)
      end
      if removed.is_entering then
        local dest_room = self.world:getRoom(removed.x, removed.y)
        self:unexpectFromRoom(dest_room)
        if dest_room and removed.reserve_on_resume and
            removed.reserve_on_resume:isReservedFor(self) then
          removed.reserve_on_resume:removeReservedUser(self)
          dest_room:tryAdvanceQueue()
        end
      end
    end
  end

  -- Add the new action to the queue
  queue[i] = action

  -- Interrupt the current action and queue other actions to be interrupted
  -- when they start.
  if interrupted then
    local current_action = queue[1]
    for j = 1, i - 1 do
      queue[j].todo_interrupt = high_priority and "high" or true
    end
    -- Try to interrupt current action
    if not current_action.uninterruptible then
      local interrupt_handler = current_action.on_interrupt
      if interrupt_handler then
        current_action.on_interrupt = nil
        interrupt_handler(current_action, self, high_priority or false)
      end
    end
  else
    -- Start the action if it has become the current action
    self:startAction()
  end
  return self
end

function Humanoid:queueAction(action, pos)
  if pos then
    table.insert(self.action_queue, pos + 1, action)
    if pos == 0 then
      self:startAction()
    end
  else
    self.action_queue[#self.action_queue + 1] = action
  end
  return self
end


function Humanoid:finishAction(action)
  if action ~= nil then
    assert(action == self.action_queue[1], "Can only finish current action")
  end
  -- Save the previous action just a while longer.
  self.previous_action = self.action_queue[1]
  table.remove(self.action_queue, 1)
  self:startAction()
end

-- Check if the humanoid is running actions intended to leave the room, as indicated by the flag
function Humanoid:isLeaving()
  return self.action_queue[1].is_leaving and true or false
end

-- Check if there is "is_leaving" action in the action queue
function Humanoid:hasLeavingAction()
  for _, action in ipairs(self.action_queue) do
    if action.is_leaving then
      return true
    end
  end
  return false
end

--! Handle an empty action queue in some way instead of crashing.
function Humanoid:_handleEmptyActionQueue()
  -- if this is a patient that is going home, an empty
  -- action queue is not a problem
  if class.is(self, Patient) and self.going_home then
    return
  end

  -- First find out if this humanoid is in a room.
  local room = self:getRoom()
  if room then
    room:makeHumanoidLeave(self)
  end

  -- Give the humanoid an action to avoid crashing.
  if class.is(self, Staff) then
    self:queueAction(MeanderAction())
  elseif class.is(self, GrimReaper) then
    self:queueAction(IdleAction())
  else
    self:queueAction(SeekReceptionAction())
  end

  -- Open the dialog of the humanoid as feedback to the user.
  local ui = self.world.ui
  if class.is(self, Patient) then
    ui:addWindow(UIPatient(ui, self))
  elseif class.is(self, Staff) then
    ui:addWindow(UIStaff(ui, self))
  end

  -- Tell the player what just happened.
  self.world:gameLog("")
  self.world:gameLog("Empty action queue!")
  self.world:gameLog("Last action: " .. self.previous_action.name)
  self.world:gameLog(debug.traceback())

  ui:addWindow(UIConfirmDialog(ui, true, _S.errors.dialog_empty_queue,
    --[[persistable:humanoid_leave_hospital]] function()
      self.world:gameLog("The humanoid was told to leave the hospital...")
      if class.is(self, Staff) then
        self:fire()
      else
        -- Set these variables to increase the likelihood of the humanoid managing to get out of the hospital.
        self.going_home = false
        self.hospital = self.world:getLocalPlayerHospital()
        self:goHome("kicked")
      end
    end,
    nil -- Do nothing on cancel
  ))
end

function Humanoid:setType(humanoid_class)
  assert(walk_animations[humanoid_class], "Invalid humanoid class: " .. tostring(humanoid_class))
  self.walk_anims = walk_animations[humanoid_class]
  self.door_anims = door_animations[humanoid_class]
  self.die_anims  = die_animations[humanoid_class]
  self.falling_anim  = falling_animations[humanoid_class]
  self.on_ground_anim  = on_ground_animations[humanoid_class]
  self.get_up_anim  = get_up_animations[humanoid_class]
  self.shake_fist_anim  = shake_fist_animations[humanoid_class]
  self.vomit_anim = vomit_animations[humanoid_class]
  self.yawn_anim = yawn_animations[humanoid_class]
  self.tap_foot_anim = tap_foot_animations[humanoid_class]
  self.check_watch_anim = check_watch_animations[humanoid_class]
  self.pee_anim = pee_animations[humanoid_class]
  self.humanoid_class = humanoid_class
  if #self.action_queue == 0 then
    self:setNextAction(IdleAction())
  end

  self.th:setPartialFlag(self.permanent_flags or 0, false)
  if humanoid_class == "Invisible Patient" then
    -- Invisible patients do not have very many pixels to hit, box works better
    self.permanent_flags = DrawFlags.BoundBoxHitTest
  else
    self.permanent_flags = nil
  end
  self.th:setPartialFlag(self.permanent_flags or 0)
end

-- Helper function for the common case of instructing a `Humanoid` to walk to
-- a position on the map. Equivalent to calling `setNextAction` with a walk
-- action.
--!param tile_x (integer) The X-component of the Lua tile coordinates of the
-- tile to walk to.
--!param tile_y (integer) The Y-component of the Lua tile coordinates of the
-- tile to walk to.
--!param must_happen (boolean, nil) If true, then the walk action will not be
-- interrupted.
function Humanoid:walkTo(tile_x, tile_y, must_happen)
  self:setNextAction(WalkAction(tile_x, tile_y)
      :setMustHappen(not not must_happen))
end

-- Stub functions for handling fatigue. These are overridden by the staff subclass,
-- but also defined here, so we can just call it on any humanoid
function Humanoid:tire(amount)
end

function Humanoid:wake(amount)
end

function Humanoid:updateSpeed()
  self.speed = "normal"
end

function Humanoid:handleRemovedObject(object)
  local replacement_action
  if self.humanoid_class and self.humanoid_class == "Receptionist" then
    replacement_action = MeanderAction()
  elseif object.object_type.id == "bench" or object.object_type.id == "drinks_machine" then
    replacement_action = IdleAction():setMustHappen(true)
  end

  for i, action in ipairs(self.action_queue) do
    if (action.name == "use_object" or action.name == "staff_reception") and action.object == object then
      if replacement_action then
        self:queueAction(replacement_action, i)
      end
      if i == 1 then
        local on_interrupt = action.on_interrupt
        action.on_interrupt = nil
        if on_interrupt then
          on_interrupt(action, self, true)
        end
      else
        table.remove(self.action_queue, i)
        self.associated_desk = nil -- NB: for the other case, this is already handled in the on_interrupt function
      end
      -- Are we in a queue?
      if self.action_queue[i + 1] and self.action_queue[i + 1].name == "queue" then
        self.action_queue[i + 1]:onChangeQueuePosition(self)
      end
      break
    end
  end
end

-- Adjusts one of the `Humanoid`'s attributes.
--!param attribute (string) One of: "happiness", "thirst", "toilet_need", "warmth".
--!param amount (number) This amount is added to the existing value for the attribute,
--  and is then capped to be between 0 and 1.
function Humanoid:changeAttribute(attribute, amount)
  -- Handle some happiness special cases
  if attribute == "happiness" and self.humanoid_class then
    local max_salary = self.world.map.level_config.payroll.MaxSalary
    if self.humanoid_class == "Receptionist" then
      -- A receptionist is never unhappy
      self.attributes[attribute] = 1
      return true
    elseif self.profile and self.profile.wage >= max_salary then
      -- A maximum salaried staff member is never unhappy
      self.attributes[attribute] = 1
      return true
    end
  end

  if self.attributes[attribute] then
    self.attributes[attribute] = self.attributes[attribute] + amount
    if self.attributes[attribute] > 1 then
      self.attributes[attribute] = 1
    elseif self.attributes[attribute] < 0 then
      self.attributes[attribute] = 0
    end
  end
end

-- Check if it is cold or hot around the humanoid and increase/decrease the
-- feeling of warmth accordingly. Returns whether the calling function should proceed.
function Humanoid:tickDay()
  -- No use doing anything if we're going home/fired (or dead)
  if self.going_home or self.dead then
    return false
  end

  local temperature = self.world.map.th:getCellTemperature(self.tile_x, self.tile_y)
  self.attributes.warmth = self:getAttribute("warmth") * 0.75 + temperature * 0.25

  -- If it is too hot or too cold, start to decrease happiness and
  -- show the corresponding icon. Otherwise we could get happier instead.
  local min_comfort_temp = 0.22 -- 11 degrees Celsius.
  local max_comfort_temp = 0.36 -- 18 degrees Celsius.
  local decrease_factor = 0.10
  local increase_happiness = 0.005
  local warmth = self:getAttribute("warmth")

  if warmth and self.hospital then
    -- Cold: less than comfortable.
    if warmth < min_comfort_temp then
      self:changeAttribute("happiness", -decrease_factor * (min_comfort_temp - warmth))
      self:setMood("cold", "activate")
    -- Hot: More than comfortable.
    elseif warmth > max_comfort_temp then
      self:changeAttribute("happiness", -decrease_factor * (warmth - max_comfort_temp))
      self:setMood("hot", "activate")
    -- Ideal: Not too cold or too warm.
    else
      self:changeAttribute("happiness", increase_happiness)
      self:setMood("cold", "deactivate")
      self:setMood("hot", "deactivate")
    end
  end
  return true
end

-- Helper function that finds out if there is an action queued to use the specified object
function Humanoid:goingToUseObject(object_type)
  for _, action in ipairs(self.action_queue) do
    if action.object and action.object.object_type.id == object_type then
      return true
    end
  end
  return false
end

-- Registers a new build callback for this humanoid.
--!param callback (function) The callback to call when a room has been built.
function Humanoid:registerRoomBuildCallback(callback)
  if not self.build_callbacks[callback] then
    self.build_callbacks[callback] = true
  else
    self.world:gameLog("Warning: Trying to re-add room build callback (" .. tostring(callback) .. ") for humanoid (" .. tostring(self) .. ").")
  end
end

-- Unregisters a build callback for this humanoid.
--!param callback (function) The callback to remove.
function Humanoid:unregisterRoomBuildCallback(callback)
  self.build_callbacks[callback] = nil
end

function Humanoid:notifyNewRoom(room)
  for callback, _ in pairs(self.build_callbacks) do
    callback(room)
  end
end

function Humanoid:notifyOfStaffChange(staff)
  for callback, _ in pairs(self.staff_change_callbacks) do
    callback(staff)
  end
end

-- Registers a new remove callback for this humanoid.
--!param callback (function) The callback to call when a room has been removed.
function Humanoid:registerRoomRemoveCallback(callback)
  if not self.remove_callbacks[callback] then
    self.world:registerRoomRemoveCallback(callback)
    self.remove_callbacks[callback] = true
  else
    self.world:gameLog("Warning: Trying to re-add room remove callback (" .. tostring(callback) .. ") for humanoid (" .. tostring(self) .. ").")
  end
end

-- Unregisters a remove callback for this humanoid.
--!param callback (function) The callback to remove.
function Humanoid:unregisterRoomRemoveCallback(callback)
  if self.remove_callbacks[callback] then
    self.world:unregisterRoomRemoveCallback(callback)
    self.remove_callbacks[callback] = nil
  end
end


-- Registers a new staff change callback for this humanoid.
--!param callback (function) The callback to call when a staff member has been hired or fired
function Humanoid:registerStaffChangeCallback(callback)
  if self.staff_change_callbacks and not self.staff_change_callbacks[callback] then
    self.staff_change_callbacks[callback] = true
  else
    self.world:gameLog("Warning: Trying to re-add staff callback (" .. tostring(callback) .. ") for humanoid (" .. tostring(self) .. ").")
  end
end

-- Unregisters a staff change callback for this humanoid.
--!param callback (function) The callback to remove.
function Humanoid:unregisterStaffChangeCallback(callback)

  if self.staff_change_callbacks and self.staff_change_callbacks[callback] then
    self.staff_change_callbacks[callback] = nil
  else
    self.world:gameLog("Warning: Trying to remove nonexistent staff callback (" .. tostring(callback) .. ") from humanoid (" .. tostring(self) .. ").")
  end
end


-- Function called when a humanoid is sent away from the hospital to prevent
-- further actions taken as a result of a callback
function Humanoid:unregisterCallbacks()
  -- Remove callbacks for new rooms
  for cb, _ in pairs(self.build_callbacks) do
    self:unregisterRoomBuildCallback(cb)
  end
  -- Remove callbacks for removed rooms
  for cb, _ in pairs(self.remove_callbacks) do
    self:unregisterRoomRemoveCallback(cb)
  end
  -- Remove callbacks for removed rooms
  for cb, _ in pairs(self.staff_change_callbacks) do
    self:unregisterStaffChangeCallback(cb)
  end
  -- Remove any message related to the humanoid.
  if self.message_callback then
    self:message_callback(true)
    self.message_callback = nil
  end
end

function Humanoid:getDrawingLayer()
  return 4
end

function Humanoid:getCurrentAction()
  if next(self.action_queue) == nil then
    error("Action queue was empty. This should never happen.\n" .. self:tostring())
  end

  return self.action_queue[1]
end

--[[ Return string representation
! Returns string representation of the humanoid like status and action queue
!return (string)
]]
function Humanoid:tostring()
  local name = self.profile and self.profile:getFullName() or nil
  local class = self.humanoid_class and self.humanoid_class or "N/A"
  local full_name = "humanoid"
  if (name) then
    full_name = full_name .. " (" .. name .. ")"
  end

  local result = string.format("%s - class: %s", full_name, class)

  result = result .. string.format("\nWarmth: %.3f   Happiness: %.3f   Fatigue: %.3f  Thirst: %.3f  Toilet_Need: %.3f   Health: %.3f   Service Quality: %.3f",
    self:getAttribute("warmth"),
    self:getAttribute("happiness"),
    self:getAttribute("fatigue"),
    self:getAttribute("thirst"),
    self:getAttribute("toilet_need"),
    self:getAttribute("health"),
    self.getServiceQuality and self:getServiceQuality() or 0)

  result = result .. "\nActions: ["
  for i = 1, #self.action_queue do
    local action = self.action_queue[i]
    local action_string = action.name
    if action.room_type then
      action_string = action_string .. " - " .. action.room_type
    elseif action.object then
      action_string = action_string .. " - " .. action.object.object_type.id
    elseif action.name == "walk" then
      action_string = action_string .. " - going to " .. action.x .. ":" .. action.y
    elseif action.name == "queue" then
      local distance = action.current_bench_distance
      if distance == nil then
        distance = "nil"
      end
      local standing = "false"
      if action.isStanding and action:isStanding() then
        standing = "true"
      end
      action_string = action_string .. " - Bench distance: " .. distance .. " Standing: " .. standing
    end
    local flag = action.must_happen and "  must_happen" or ""
    if flag ~= "" then
      action_string = action_string .. " " .. flag
    end

    if i ~= 1 then
      result = result .. ", "
    end
    result = result .. action_string
  end
  result = result .. "]"
  return result
end

--! Unexpects humanoid from a room, if validly entering this room
--!param dest_room (Room) The room the humanoid maybe expected at
function Humanoid:unexpectFromRoom(dest_room)
  -- Unexpect the patient from a possible destination room.
  if dest_room and dest_room.door.queue then
    -- 1st condition checks normal room routing
    -- 2nd checks patients going to toilets, doctors and nurses
    -- and redundantly checks patients routed between rooms
    if self.next_room_to_visit == dest_room or
        (dest_room ~= self.next_room_to_visit and (not self:getRoom() or class.is(self, Staff))) then
      dest_room.door.queue:unexpect(self)
      dest_room.door:updateDynamicInfo()
    end
  end
 end

-- Get attribute value
--!param attribute (string)
--!param default_value (float) Number to return if none found. If neither are present, 0 is returned
--!return (float)
function Humanoid:getAttribute(attribute, default_value)
  return self.attributes[attribute] or default_value or 0
end

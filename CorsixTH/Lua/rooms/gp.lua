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

local room = {}
room.id = "gp"
room.vip_must_visit = false
room.level_config_id = 7
room.class = "GPRoom"
room.name = _S.rooms_short.gps_office
room.long_name = _S.rooms_long.gps_office
room.tooltip = _S.tooltip.rooms.gps_office
room.objects_additional = { "extinguisher", "radiator", "plant", "bin" }
room.objects_needed = { desk = 1, cabinet = 1, chair = 1 }
room.build_preview_animation = 900
room.categories = {
  diagnosis = 1,
}
room.minimum_size = 4
room.wall_type = "white"
room.floor_tile = 18
room.required_staff = {
  Doctor = 1,
}
room.maximum_staff = room.required_staff
room.call_sound = "reqd008.wav"

class "GPRoom" (Room)

---@type GPRoom
local GPRoom = _G["GPRoom"]

function GPRoom:GPRoom(...)
  self:Room(...)
end

function GPRoom:doStaffUseCycle(humanoid)
  local obj, ox, oy = self.world:findObjectNear(humanoid, "cabinet")
  humanoid:walkTo(ox, oy)
  humanoid:queueAction(UseObjectAction(obj))

  obj, ox, oy = self.world:findObjectNear(humanoid, "desk")
  humanoid:queueAction(WalkAction(ox, oy))

  -- A skilled doctor requires less time at the desk to diagnose the patient
  local inv_skill = 1 - humanoid.profile.skill
  local desk_use_time = math.random(math.floor(3 +  5 * inv_skill),
                                    math.ceil (8 + 10 * inv_skill))
  local gp_loop_callback = --[[persistable:gp_loop_callback]] function()
    desk_use_time = desk_use_time - 1
    if desk_use_time == 0 then
      -- Consultants who aren't tired might not need to stretch their legs
      -- to remain alert, so might just remain at the desk and deal with the
      -- next patient quicker.
      if humanoid.profile.is_consultant and
          math.random() >= humanoid:getAttribute("fatigue") then
        desk_use_time = math.random(7, 14)
      else
        self:doStaffUseCycle(humanoid)
      end

      local patient = self:getPatient()
      if patient then
        if math.random() <= (0.7 + 0.3 * humanoid.profile.skill) or self.max_times <= 0 then
          if patient.user_of and not class.is(patient.user_of, Door) then
            self:dealtWithPatient(patient)
          end
        else
          self.max_times = self.max_times - 1
        end
      end
    end
  end

  humanoid:queueAction(UseObjectAction(obj):setLoopCallback(gp_loop_callback))
end

function GPRoom:commandEnteringStaff(humanoid)
  self.staff_member = humanoid
  self:doStaffUseCycle(humanoid)
  return Room.commandEnteringStaff(self, humanoid, true)
end

function GPRoom:commandEnteringPatient(humanoid)
  local obj, ox, oy = self.world:findObjectNear(humanoid, "chair")
  humanoid:walkTo(ox, oy)
  humanoid:queueAction(UseObjectAction(obj))
  self.max_times = 3
  return Room.commandEnteringPatient(self, humanoid)
end

function GPRoom:shouldHavePatientReenter(patient)
  return not patient.diagnosed and Room.shouldHavePatientReenter(self, patient)
end

function GPRoom:dealtWithPatient(patient)
  patient = patient or self:getPatient()

  -- If patients are slow to leave the chair, and staff are quick in their
  -- usage cycle, then dealtWithPatient() might get called twice for the
  -- same patient, in which case the second call must be ignored (otherwise
  -- if the first call resulted in the patient being diagnosed, the following
  -- logic would cause the patient to leave the room and stand indefinitely).
  if patient == self.just_dealt_with then
    return
  else
    self.just_dealt_with = patient
  end

  patient:setNextAction(self:createLeaveAction())
  patient:addToTreatmentHistory(self.room_info)

  -- If the patient got sent to the wrong room and needs telling where
  -- to go next - this happens when a disease changes for an epidemic
  if patient.needs_redirecting then
    self:sendPatientToNextDiagnosisRoom(patient)
    patient.needs_redirecting = false
  elseif patient.disease and not patient.diagnosed then
    self.hospital:receiveMoneyForTreatment(patient)
    patient:completeDiagnosticStep(self)
    if patient.diagnosis_progress >= self.hospital.policies["stop_procedure"] then
      patient:setDiagnosed()
      if patient:agreesToPay(patient.disease.id) then
        patient:queueAction(SeekRoomAction(patient.disease.treatment_rooms[1]):enableTreatmentRoom())
      else
        patient:goHome("over_priced", patient.disease.id)
      end

      self.staff_member:setMood("idea3", "activate") -- Show the light bulb over the doctor
      -- Check if this disease has just been discovered
      if not self.hospital.disease_casebook[patient.disease.id].discovered then
        self.hospital.research:discoverDisease(patient.disease)
      end
    else
      self:sendPatientToNextDiagnosisRoom(patient)
    end
  else
    patient:queueAction(MeanderAction():setCount(2))
    patient:queueAction(IdleAction())
  end

  if self.dealt_patient_callback then
    self.dealt_patient_callback(self.waiting_staff_member)
  end
  if self.staff_member then
    self:setStaffMembersAttribute("dealing_with_patient", false)
  end
end

function GPRoom:sendPatientToNextDiagnosisRoom(patient)
  if #patient.available_diagnosis_rooms == 0 then
    -- The very rare case where the patient has visited all his/her possible diagnosis rooms
    -- There's not much to do then... Send home
    patient:goHome("kicked")
    patient:setDynamicInfoText(_S.dynamic_info.patient.actions.no_diagnoses_available)
  else
    self.staff_member:setMood("reflexion", "activate") -- Show the uncertainty mood over the doctor
    local next_room_id = math.random(1, #patient.available_diagnosis_rooms)
    local next_room = patient.available_diagnosis_rooms[next_room_id]
    if patient:agreesToPay("diag_" .. next_room) then
      patient:queueAction(SeekRoomAction(next_room):setDiagnosisRoom(next_room_id))
    else
      patient:goHome("over_priced", "diag_" .. next_room)
    end
  end
end

function GPRoom:onHumanoidLeave(humanoid)
  -- Reset moods when either the patient or the doctor leaves the room.
  if humanoid.humanoid_class ~= "Handyman" then
    for staff, _ in pairs(self.humanoids) do
      staff:setMood("idea3", "deactivate")
      staff:setMood("reflexion", "deactivate")
    end
  end
  if self.staff_member == humanoid then
    self.staff_member = nil
  end
  if self.just_dealt_with == humanoid then
    self.just_dealt_with = nil
  end
  Room.onHumanoidLeave(self, humanoid)
end

function GPRoom:roomFinished()
  if self.hospital:countStaffOfCategory("Doctor") == 0 and
      not self.world.ui.start_tutorial then
    self.hospital:giveAdvice({_A.room_requirements.gps_office_need_doctor})
  end
  return Room.roomFinished(self)
end

return room

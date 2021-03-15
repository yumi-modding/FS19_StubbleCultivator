-- StubbleSowingMachine
-- Spec for StubbleSowingMachine to be used with FS19 default chopped straw
-- When activated, the SowingMachine will work the soil but let the choppedStraw layer
-- by yumi

source(Utils.getFilename("StubbleSowingMachineEvent.lua", g_currentModDirectory.."scripts/"))

StubbleSowingMachine = {};

StubbleSowingMachine.debug = false --true --
StubbleSowingMachine.modName = g_currentModName

function StubbleSowingMachine.prerequisitesPresent(specializations)
  if StubbleSowingMachine.debug then print("StubbleSowingMachine:prerequisitesPresent()") end
  return SpecializationUtil.hasSpecialization(SowingMachine, specializations);
end;

function StubbleSowingMachine.registerEvents(vehicleType)
  if StubbleSowingMachine.debug then print("StubbleSowingMachine:registerEvents() ") end
	SpecializationUtil.registerEvent(vehicleType, "onChangedStubbleSowingMachine")
end

function StubbleSowingMachine.registerFunctions(vehicleType)
	if StubbleSowingMachine.debug then print("StubbleSowingMachine:registerFunctions() ") end
  SpecializationUtil.registerFunction(vehicleType, "setStubbleSowingMachineActive", StubbleSowingMachine.setStubbleSowingMachineActive)
  SpecializationUtil.registerFunction(vehicleType, "getIsStubbleSowingMachineActive", StubbleSowingMachine.getIsStubbleSowingMachineActive)
  SpecializationUtil.registerFunction(vehicleType, "getIsStubbleSowingMachineAlwaysActive", StubbleSowingMachine.getIsStubbleSowingMachineAlwaysActive)
end

function StubbleSowingMachine.registerOverwrittenFunctions(vehicleType)
	if StubbleSowingMachine.debug then print("StubbleSowingMachine:registerOverwrittenFunctions() ") end
  SpecializationUtil.registerOverwrittenFunction(vehicleType, "processSowingMachineArea", StubbleSowingMachine.processSowingMachineArea)
end

function StubbleSowingMachine.registerEventListeners(vehicleType)
	if StubbleSowingMachine.debug then print("StubbleSowingMachine:registerEventListeners() ") end
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", StubbleSowingMachine)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", StubbleSowingMachine)
  SpecializationUtil.registerEventListener(vehicleType, "onReadStream", StubbleSowingMachine)
  SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", StubbleSowingMachine)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", StubbleSowingMachine)
	SpecializationUtil.registerEventListener(vehicleType, "onChangedStubbleSowingMachine", StubbleSowingMachine)
end

function StubbleSowingMachine:onLoad(savegame)
  if StubbleSowingMachine.debug then print("StubbleSowingMachine:onLoad() ") end
  local spec = self["spec_"..StubbleSowingMachine.modName..".StubbleSowingMachine"]
  spec.isStubbleSowingMachineActive = false;
  spec.isStubbleSowingMachineAlwaysActive = false;
  if savegame ~= nil then
    local isStubbleSowingMachineActive = Utils.getNoNil(getXMLBool(savegame.xmlFile, savegame.key.."."..StubbleSowingMachine.modName..".StubbleSowingMachine#StubbleSowingMachine"), false);
    local isStubbleSowingMachineAlwaysActive = Utils.getNoNil(getXMLBool(savegame.xmlFile, savegame.key.."."..StubbleSowingMachine.modName..".StubbleSowingMachine#Always"), false);
    -- if isStubbleSowingMachineActive == nil then
    --   self:setStubbleSowingMachineActive(false);
    -- else
      self:setStubbleSowingMachineActive(isStubbleSowingMachineActive, isStubbleSowingMachineAlwaysActive);
    -- end
  else
      self:setStubbleSowingMachineActive(false, false);
  end;
end;

function StubbleSowingMachine:saveToXMLFile(xmlFile, key, usedModNames)
  if StubbleSowingMachine.debug then print("StubbleSowingMachine:saveToXMLFile() ") end
  local spec = self["spec_"..StubbleSowingMachine.modName..".StubbleSowingMachine"]
  setXMLBool(xmlFile, key.."#StubbleSowingMachine", spec.isStubbleSowingMachineActive)
  setXMLBool(xmlFile, key.."#Always", spec.isStubbleSowingMachineAlwaysActive)
end;

function StubbleSowingMachine:onReadStream(streamId, connection)
  local isActive = streamReadBool(streamId)
  local isAlwaysActive = streamReadBool(streamId)
  if StubbleSowingMachine.debug then print("StubbleSowingMachine:onReadStream() "..tostring(isActive)) end
  if StubbleSowingMachine.debug then print("StubbleSowingMachine:onReadStream() "..tostring(isAlwaysActive)) end
  self:setStubbleSowingMachineActive(isActive, isAlwaysActive, true);
end;

function StubbleSowingMachine:onWriteStream(streamId, connection)
  local spec = self["spec_"..StubbleSowingMachine.modName..".StubbleSowingMachine"]
  if StubbleSowingMachine.debug then print("StubbleSowingMachine:onWriteStream() "..tostring(spec.isStubbleSowingMachineActive)) end
  if StubbleSowingMachine.debug then print("StubbleSowingMachine:onWriteStream() "..tostring(spec.isStubbleSowingMachineAlwaysActive)) end
  streamWriteBool(streamId, spec.isStubbleSowingMachineActive);
  streamWriteBool(streamId, spec.isStubbleSowingMachineAlwaysActive);
end;

function StubbleSowingMachine:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
  local spec = self["spec_"..StubbleSowingMachine.modName..".StubbleSowingMachine"]
  if self.isClient then
    if spec.actionEvents ~= nil then
      local actionEvent = spec.actionEvents['STUBBLE_OnOffStubbleCultivator']
      if actionEvent ~= nil and actionEvent.actionEventId ~= nil then
        local isActive = self:getIsStubbleSowingMachineActive()
        local isAlwaysActive = self:getIsStubbleSowingMachineAlwaysActive()
        local text
        if isActive then
          if isAlwaysActive then
            text = string.format(g_i18n:getText("StubbleSowingMachine_AlwaysActivated"))
          else
            text = string.format(g_i18n:getText("StubbleSowingMachine_Activated"))
          end
        else
          text = string.format(g_i18n:getText("StubbleSowingMachine_Deactivated"))
        end
        g_inputBinding:setActionEventText(actionEvent.actionEventId, text)
      end
    end
  end
end;

-- @doc register InputBindings
function StubbleSowingMachine:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
  if StubbleSowingMachine.debug then print("StubbleSowingMachine:onRegisterActionEvents()") end
  local spec = self["spec_"..StubbleSowingMachine.modName..".StubbleSowingMachine"]
  self:clearActionEventsTable(spec.actionEvents)
  if isActiveForInputIgnoreSelection then
    StubbleSowingMachine.inputActionEventIds = {}
		for index, action in pairs (g_gui.inputManager.nameActions) do
			if string.match(index,'STUBBLE_') then
        local _, eventId = self:addActionEvent(spec.actionEvents, index, self, StubbleSowingMachine.actionEventSetActive, false, true, false, true, nil);
        StubbleSowingMachine.inputActionEventIds[index] = eventId;
        g_inputBinding:setActionEventTextPriority(eventId, GS_PRIO_NORMAL)
        g_gui.inputManager:setActionEventTextVisibility(eventId, true)
      end
    end
  end
end

function StubbleSowingMachine.actionEventSetActive(self, actionName, inputValue, callbackState, isAnalog)
  if StubbleSowingMachine.debug then print("StubbleSowingMachine.actionEventSetActive "..tostring(actionName)) end
  local spec = self["spec_"..StubbleSowingMachine.modName..".StubbleSowingMachine"]
  if actionName == 'STUBBLE_OnOffStubbleCultivator' then
    if not spec.isStubbleSowingMachineActive then
      if StubbleSowingMachine.debug then print("StubbleSowingMachine On") end
      -- On
      self:setStubbleSowingMachineActive(true, false);
    else
      if not spec.isStubbleSowingMachineAlwaysActive then
        if StubbleSowingMachine.debug then print("StubbleSowingMachine Always") end
        -- Always
        self:setStubbleSowingMachineActive(true, true);
      else
        if StubbleSowingMachine.debug then print("StubbleSowingMachine Off") end
        -- Off
        self:setStubbleSowingMachineActive(false, false);
      end
    end
  end
end

function StubbleSowingMachine:processSowingMachineArea(superfunc, workArea, dt)
  local xs,ys,zs = getTranslation(workArea.start)
  local xw,yw,zw = getTranslation(workArea.width)
  local xh,yh,zh = getTranslation(workArea.height)

	local checkDir = 0
	if self.movingDirection ~= 0 then
		checkDir = self.movingDirection
	end

  local _xs, _ys, _zs = localToWorld(self.components[1].node, xs, ys, zs + checkDir) -- check 1m in front of the working area
  local _xw, _yw, _zw = localToWorld(self.components[1].node, xw, yw, zw + checkDir) -- check 1m in front of the working area
  local _xh, _yh, _zh = localToWorld(self.components[1].node, xh, yh, zh + checkDir) -- check 1m in front of the working area

  local x, z, widthX, widthZ, heightX, heightZ = MathUtil.getXZWidthAndHeight(_xs, _zs, _xw, _zw, _xh, _zh)

  if StubbleSowingMachine.debug then DebugUtil.drawDebugParallelogram(x, z, widthX, widthZ, heightX, heightZ, 2, 1, 0, 0, 1) end

  local excludedFruits = {  "WEED", "COTTON" }

  -- Get current fruit on the groud
  local fruitIdx = nil;
  for fruitIndex, fruit in pairs(g_currentMission.fruits) do
      -- print("fruitIndex "..tostring(fruitIndex))
      -- print("fruit "..tostring(fruit))
      -- DebugUtil.printTableRecursively(fruit, " ", 1, 2);
      local requiredFruitType = g_fruitTypeManager.fruitTypes[fruitIndex]
      local query = g_currentMission.fieldCropsQuery
      if requiredFruitType ~= FruitType.UNKNOWN then
          local minState = requiredFruitType.minHarvestingGrowthState + 1
          local maxState = requiredFruitType.cutState + 1
          if fruit ~= nil and fruit.id ~= 0 then
              query:addRequiredCropType(fruit.id, minState,  maxState, requiredFruitType.startStateChannel, requiredFruitType.numStateChannels, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels)
          end
      end
      local area, _ = query:getParallelogram(x, z, widthX, widthZ, heightX, heightZ, true)
      -- print("area: "..tostring(area))
      if area > 0 then
        local isExcludedFruit = false
        for _, excludedFruit in pairs(excludedFruits) do
          if requiredFruitType.name == excludedFruit then
            isExcludedFruit = true
            break
          end
        end
        if not isExcludedFruit then
          -- print("requiredFruitType "..tostring(requiredFruitType.name))
          -- print("requiredfillType  "..tostring(requiredFruitType.fillType.name))
          if fruitIdx == nil then
            fruitIdx = fruitIndex
            break
          end
        end
      end
  end

  -- Start by applying SowingMachine layer type
  local realArea, area = superfunc(self, workArea, dt)

  -- Then choppedStraw if active
  if self:getIsStubbleSowingMachineActive() and (fruitIdx ~= nil or self:getIsStubbleSowingMachineAlwaysActive()) then
    local wxs,_,wzs = getWorldTranslation(workArea.start)
    local wxw,_,wzw = getWorldTranslation(workArea.width)
    local wxh,_,wzh = getWorldTranslation(workArea.height)
  
    FSDensityMapUtil.setGroundTypeLayerArea(wxs, wzs, wxw, wzw, wxh, wzh, g_currentMission.chopperGroundLayerType)
    self:raiseActive()
  end

  return realArea, area
end

function StubbleSowingMachine:setStubbleSowingMachineActive(isActive, isAlwaysActive, noEventSend)
  if StubbleSowingMachine.debug then print("StubbleSowingMachine:setStubbleSowingMachineActive() "..tostring(isActive)) end
  if StubbleSowingMachine.debug then print("StubbleSowingMachine:setStubbleSowingMachineActive() "..tostring(isAlwaysActive)) end
  local spec = self["spec_"..StubbleSowingMachine.modName..".StubbleSowingMachine"]
  if isActive ~= spec.isStubbleSowingMachineActive or isAlwaysActive ~= spec.isStubbleSowingMachineAlwaysActive then
    StubbleSowingMachineEvent.sendEvent(self, isActive, isAlwaysActive, noEventSend);
    spec.isStubbleSowingMachineActive = isActive
    spec.isStubbleSowingMachineAlwaysActive = isAlwaysActive
    SpecializationUtil.raiseEvent(self, "onChangedStubbleSowingMachine")
  end;
end;

function StubbleSowingMachine:getIsStubbleSowingMachineActive()
  local spec = self["spec_"..StubbleSowingMachine.modName..".StubbleSowingMachine"]
   return spec.isStubbleSowingMachineActive
end;

function StubbleSowingMachine:getIsStubbleSowingMachineAlwaysActive()
  local spec = self["spec_"..StubbleSowingMachine.modName..".StubbleSowingMachine"]
   return spec.isStubbleSowingMachineAlwaysActive
end;

function StubbleSowingMachine:onChangedStubbleSowingMachine()
  if StubbleSowingMachine.debug then print("StubbleSowingMachine:onChangedStubbleSowingMachine() ") end

end

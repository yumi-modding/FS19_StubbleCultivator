-- StubbleCultivator
-- Spec for StubbleCultivator to be used with FS19 default chopped straw
-- When activated, the cultivator will work the soil but let the choppedStraw layer to have distinct visible behavior between Stubble Cultivator and Standard Cultivator
-- by yumi

source(Utils.getFilename("StubbleCultivatorEvent.lua", g_currentModDirectory.."scripts/"))

StubbleCultivator = {};

StubbleCultivator.debug = false --true --
StubbleCultivator.modName = g_currentModName

function StubbleCultivator.prerequisitesPresent(specializations)
  if StubbleCultivator.debug then print("StubbleCultivator:prerequisitesPresent()") end
  return SpecializationUtil.hasSpecialization(Cultivator, specializations);
end;

function StubbleCultivator.registerEvents(vehicleType)
  if StubbleCultivator.debug then print("StubbleCultivator:registerEvents() ") end
	SpecializationUtil.registerEvent(vehicleType, "onChangedStubbleCultivator")
end

function StubbleCultivator.registerFunctions(vehicleType)
	if StubbleCultivator.debug then print("StubbleCultivator:registerFunctions() ") end
  SpecializationUtil.registerFunction(vehicleType, "setStubbleCultivatorActive", StubbleCultivator.setStubbleCultivatorActive)
  SpecializationUtil.registerFunction(vehicleType, "getIsStubbleCultivatorActive", StubbleCultivator.getIsStubbleCultivatorActive)
end

function StubbleCultivator.registerOverwrittenFunctions(vehicleType)
	if StubbleCultivator.debug then print("StubbleCultivator:registerOverwrittenFunctions() ") end
  SpecializationUtil.registerOverwrittenFunction(vehicleType, "processCultivatorArea", StubbleCultivator.processCultivatorArea)
end

function StubbleCultivator.registerEventListeners(vehicleType)
	if StubbleCultivator.debug then print("StubbleCultivator:registerEventListeners() ") end
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", StubbleCultivator)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", StubbleCultivator)
  SpecializationUtil.registerEventListener(vehicleType, "onReadStream", StubbleCultivator)
  SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", StubbleCultivator)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", StubbleCultivator)
	SpecializationUtil.registerEventListener(vehicleType, "onChangedStubbleCultivator", StubbleCultivator)
end

function StubbleCultivator:onLoad(savegame)
  if StubbleCultivator.debug then print("StubbleCultivator:onLoad() ") end
  local spec = self["spec_"..StubbleCultivator.modName..".StubbleCultivator"]
  spec.isStubbleCultivatorActive = false;
  if savegame ~= nil then
    local isStubbleCultivatorActive = Utils.getNoNil(getXMLBool(savegame.xmlFile, savegame.key.."."..StubbleCultivator.modName..".StubbleCultivator#StubbleCultivator"), false);
    if isStubbleCultivatorActive == nil then
      self:setStubbleCultivatorActive(false);
    else
      self:setStubbleCultivatorActive(isStubbleCultivatorActive);
    end
  else
      self:setStubbleCultivatorActive(false);
  end;
end;

function StubbleCultivator:saveToXMLFile(xmlFile, key, usedModNames)
  if StubbleCultivator.debug then print("StubbleCultivator:saveToXMLFile() ") end
  local spec = self["spec_"..StubbleCultivator.modName..".StubbleCultivator"]
  setXMLBool(xmlFile, key.."#StubbleCultivator", spec.isStubbleCultivatorActive)
end;

function StubbleCultivator:onReadStream(streamId, connection)
  local isActive = streamReadBool(streamId)
  if StubbleCultivator.debug then print("StubbleCultivator:onReadStream() "..tostring(isActive)) end
  self:setStubbleCultivatorActive(isActive, true);
end;

function StubbleCultivator:onWriteStream(streamId, connection)
  local spec = self["spec_"..StubbleCultivator.modName..".StubbleCultivator"]
  if StubbleCultivator.debug then print("StubbleCultivator:onWriteStream() "..tostring(spec.isStubbleCultivatorActive)) end
  streamWriteBool(streamId, spec.isStubbleCultivatorActive);
end;

function StubbleCultivator:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
  local spec = self["spec_"..StubbleCultivator.modName..".StubbleCultivator"]
  if self.isClient then
    if spec.actionEvents ~= nil then
      local actionEvent = spec.actionEvents['STUBBLE_OnOffStubbleCultivator']
      if actionEvent ~= nil and actionEvent.actionEventId ~= nil then
        local isActive = self:getIsStubbleCultivatorActive()
        local text
        if isActive then
          text = string.format(g_i18n:getText("StubbleCultivator_Deactivate"))
        else
          text = string.format(g_i18n:getText("StubbleCultivator_Activate"))
        end
        g_inputBinding:setActionEventText(actionEvent.actionEventId, text)
      end
    end
  end
end;

-- @doc register InputBindings
function StubbleCultivator:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
  if StubbleCultivator.debug then print("StubbleCultivator:onRegisterActionEvents()") end
  local spec = self["spec_"..StubbleCultivator.modName..".StubbleCultivator"]
  self:clearActionEventsTable(spec.actionEvents)
  if isActiveForInputIgnoreSelection then
    StubbleCultivator.inputActionEventIds = {}
		for index, action in pairs (g_gui.inputManager.nameActions) do
			if string.match(index,'STUBBLE_') then
        local _, eventId = self:addActionEvent(spec.actionEvents, index, self, StubbleCultivator.actionEventSetActive, false, true, false, true, nil);
        StubbleCultivator.inputActionEventIds[index] = eventId;
        g_inputBinding:setActionEventTextPriority(eventId, GS_PRIO_NORMAL)
        g_gui.inputManager:setActionEventTextVisibility(eventId, true)
      end
    end
  end
end

function StubbleCultivator.actionEventSetActive(self, actionName, inputValue, callbackState, isAnalog)
  if StubbleCultivator.debug then print("StubbleCultivator.actionEventSetActive "..tostring(actionName)) end
  local spec = self["spec_"..StubbleCultivator.modName..".StubbleCultivator"]
  if actionName == 'STUBBLE_OnOffStubbleCultivator' then
    self:setStubbleCultivatorActive(not spec.isStubbleCultivatorActive);
  end
end

function StubbleCultivator:processCultivatorArea(superfunc, workArea, dt)
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

  if StubbleCultivator.debug then DebugUtil.drawDebugParallelogram(x, z, widthX, widthZ, heightX, heightZ, 2, 1, 0, 0, 1) end

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

  -- Start by applying cultivator layer type
  local realArea, area = superfunc(self, workArea, dt)

  -- Then choppedStraw if active
  if self:getIsStubbleCultivatorActive() and fruitIdx ~= nil then
    local wxs,_,wzs = getWorldTranslation(workArea.start)
    local wxw,_,wzw = getWorldTranslation(workArea.width)
    local wxh,_,wzh = getWorldTranslation(workArea.height)
  
    FSDensityMapUtil.setGroundTypeLayerArea(wxs, wzs, wxw, wzw, wxh, wzh, g_currentMission.chopperGroundLayerType)
    self:raiseActive()
  end

  return realArea, area
end

function StubbleCultivator:setStubbleCultivatorActive(isActive, noEventSend)
  if StubbleCultivator.debug then print("StubbleCultivator:setStubbleCultivatorActive() "..tostring(isActive)) end
  local spec = self["spec_"..StubbleCultivator.modName..".StubbleCultivator"]
  if isActive ~= spec.isStubbleCultivatorActive then
    StubbleCultivatorEvent.sendEvent(self, isActive, noEventSend);
    spec.isStubbleCultivatorActive = isActive
    SpecializationUtil.raiseEvent(self, "onChangedStubbleCultivator")
  end;
end;


function StubbleCultivator:getIsStubbleCultivatorActive()
  local spec = self["spec_"..StubbleCultivator.modName..".StubbleCultivator"]
   return spec.isStubbleCultivatorActive
end;


function StubbleCultivator:onChangedStubbleCultivator()
  if StubbleCultivator.debug then print("StubbleCultivator:onChangedStubbleCultivator() ") end

end

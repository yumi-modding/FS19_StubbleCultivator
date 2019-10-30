-- StubbleCultivator
-- Spec for StubbleCultivator to be used with chopped straw
-- by yumi


g_specializationManager:addSpecialization("StubbleCultivator", "StubbleCultivator", Utils.getFilename("StubbleCultivator.lua",  g_currentModDirectory.."scripts/"), nil)
local StubbleCultivatorSpec = g_currentModName .. ".StubbleCultivator"
g_specializationManager:addSpecialization("StubbleSowingMachine", "StubbleSowingMachine", Utils.getFilename("StubbleSowingMachine.lua",  g_currentModDirectory.."scripts/"), nil)
local StubbleSowingMachineSpec = g_currentModName .. ".StubbleSowingMachine"

StubbleCultivator_Register = {};
StubbleCultivator_Register.debug = false --true --

-- local modItem = ModsUtil.findModItemByModName(g_currentModName);
StubbleCultivator_Register.version = "1.0.0.1" --(modItem and modItem.version) and modItem.version or "1.0.0.0";

--
StubbleCultivator_Register.initialized = false

function StubbleCultivator_Register:register()
	if StubbleCultivator_Register.debug then print("StubbleCultivator_Register:register()") end

	print('*** StubbleCultivator v'..StubbleCultivator_Register.version..' specialization loading ***');

	for typeName,vehicleType in pairs(g_vehicleTypeManager.vehicleTypes) do
		if SpecializationUtil.hasSpecialization(Cultivator, vehicleType.specializations) and not vehicleType.specializationsByName[StubbleCultivatorSpec] then
			print("  install StubbleCultivator into "..typeName)
			g_vehicleTypeManager:addSpecialization(typeName, StubbleCultivatorSpec)
		end;
		if SpecializationUtil.hasSpecialization(SowingMachine, vehicleType.specializations) and not vehicleType.specializationsByName[StubbleSowingMachineSpec] then
			print("  install StubbleSowingMachine into "..typeName)
			g_vehicleTypeManager:addSpecialization(typeName, StubbleSowingMachineSpec)
		end;
	end;

end;

function StubbleCultivator_Register:onUpdate(dt)
  if not StubbleCultivator_Register.initialized then
    StubbleCultivator_Register.initialized = true -- Only initialize ONCE.
  end;
end;


StubbleCultivator_Register:register();

-- Texts
StubbleCultivator.l10nTexts = {};
StubbleCultivator.l10nTexts["StubbleCultivator_Activate"] = g_i18n:getText("StubbleCultivator_Activate");
StubbleCultivator.l10nTexts["StubbleCultivator_Deactivate"] = g_i18n:getText("StubbleCultivator_Deactivate");


-- addModEventListener(StubbleCultivator_Register);

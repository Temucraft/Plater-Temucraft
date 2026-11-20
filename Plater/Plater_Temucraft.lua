-- Plater (Temucraft): helpers the port uses to run on the 3.3.5 client, on top of !TemucraftCompat.
--
-- The 3.3.5 nameplate is a plain frame with regions (border, name, level, icons) and two status bars (health, cast).
-- Plater draws its own plate, so those parts are made invisible with SetAlpha(0) (not Hide: the compat layer reads
-- what the plate shows, like the level text and the elite icon). A small stand-in object takes the place of the
-- retail "UnitFrame" that Plater hides and shows.
local TC = TemucraftCompat
local _G = _G

PlaterTemucraft = PlaterTemucraft or {}
local PT = PlaterTemucraft
PT.Modern = TC and TC.Modern or {}

-- ------------------------------------------------------------------------------------------------ plate names
-- 3.3.5 plates have no name; Plater names its frames after the plate.
local plateCount = 0
function PT.PlateName(plate)
	local name = plate:GetName()
	if name then return name end
	if not plate.temucraftName then
		plateCount = plateCount + 1
		plate.temucraftName = "PlaterTemucraftNamePlate" .. plateCount
	end
	return plate.temucraftName
end

-- ------------------------------------------------------------------------------------------------ the 3.3.5 plate
-- Must be called before Plater adds its own regions or children to the plate.
function PT.CreateBlizzardProxy(plate)
	local parts = {}
	for _, region in ipairs({ plate:GetRegions() }) do parts[#parts + 1] = region end
	for _, child in ipairs({ plate:GetChildren() }) do parts[#parts + 1] = child end
	local proxy = { plate = plate, parts = parts, hidden = false }
	function proxy:Hide()
		self.hidden = true
		for _, part in ipairs(self.parts) do part:SetAlpha(0) end
	end
	function proxy:Show()
		self.hidden = false
		for _, part in ipairs(self.parts) do part:SetAlpha(1) end
	end
	function proxy:IsShown() return not self.hidden end
	function proxy:SetShown(shown) if shown then self:Show() else self:Hide() end end
	function proxy:UnregisterAllEvents() end
	function proxy:GetParent() return self.plate end
	return proxy
end

-- the client may show a part again (the cast bar when the target casts): hide it again while Plater owns the plate
function PT.KeepHidden(proxy)
	if not proxy or not proxy.hidden then return end
	for _, part in ipairs(proxy.parts) do
		if part:GetAlpha() > 0 then part:SetAlpha(0) end
	end
end

-- ------------------------------------------------------------------------------------------------ console variables
-- Retail nameplate CVars: a few have a 3.3.5 name, the rest don't exist and are skipped.
local CVAR_NAMES = { nameplateMotion = "spreadnameplates" }
local realSetCVar, realGetCVar = SetCVar, GetCVar
local function exists(name)
	local ok, value = pcall(realGetCVar, name)
	return ok and value ~= nil
end
PT.CVarExists = exists
function PT.SetCVar(name, value, ...)
	name = CVAR_NAMES[name] or name
	if type(name) ~= "string" or not exists(name) then return end
	if type(value) == "boolean" then value = value and "1" or "0" end
	return _G.SetCVar(name, value, ...)
end
-- a variable 3.3.5 doesn't have reads as "0", so option sliders and checkboxes still get a value
function PT.GetCVar(name)
	name = CVAR_NAMES[name] or name
	if not exists(name) then return "0" end
	return realGetCVar(name)
end
function PT.GetCVarBool(name)
	local value = PT.GetCVar(name)
	return value ~= nil and value ~= "0" and value ~= ""
end

-- ------------------------------------------------------------------------------------------------ resources
-- 3.3.5 has no combo point power type: combo points are GetComboPoints, at most 5.
local COMBO = 4
function PT.UnitPower(unit, powerType, ...)
	if powerType == COMBO then return GetComboPoints(unit, "target") or 0 end
	return UnitPower(unit, powerType, ...)
end
function PT.UnitPowerMax(unit, powerType, ...)
	if powerType == COMBO then return MAX_COMBO_POINTS or 5 end
	return UnitPowerMax(unit, powerType, ...)
end

-- the unit the client knows for a plate token (target, focus or mouseover), else the token itself
function PT.RealUnit(unit)
	local NP = TC and TC.namePlates
	if NP and NP.RealUnit then return (NP.RealUnit(unit)) or unit end
	return unit
end

-- callback(plate, token, unit or nil) when a plate gets or loses its real unit (target, focus, mouseover)
function PT.HookBinds(callback)
	local NP = TC and TC.namePlates
	if NP and NP.RegisterBindCallback then NP.RegisterBindCallback(callback) end
end

-- ------------------------------------------------------------------------------------------------ plate events
-- Frames that need unit events for plate tokens (UNIT_AURA and casts) even though they register them normally.
function PT.WantPlateEvents(frame)
	if TC and TC.namePlates and TC.namePlates.WantEvents then TC.namePlates.WantEvents(frame) end
end

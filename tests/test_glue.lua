-- standalone test of Plater/Plater_Temucraft.lua with a small fake client (run from the repo root)
local function region(alpha) return { a = alpha or 1, SetAlpha = function(s, v) s.a = v end, GetAlpha = function(s) return s.a end } end
local cvars = { spreadnameplates = "0", nameplateShowEnemies = "1" }
local sets = {}
function GetCVar(n) return cvars[n] end
function SetCVar(n, v) sets[#sets + 1] = n .. "=" .. tostring(v) cvars[n] = tostring(v) end
function GetComboPoints(u, t) return 3 end
function UnitPower(u, t) return 50 end
function UnitPowerMax(u, t) return 100 end
local bound = {}
TemucraftCompat = { Modern = { UnitAura = function() end }, namePlates = {
	RealUnit = function(u) if u == "nameplate2" then return "target" end return nil end,
	RegisterBindCallback = function(cb) bound[#bound + 1] = cb end,
	WantEvents = function(f) f.wanted = true end } }
dofile("Plater/Plater_Temucraft.lua")
local PT = PlaterTemucraft
local function ok(c, what) if not c then error("FAIL: " .. what, 2) end print("ok  " .. what) end

local glow, border, name, health, cast = region(), region(), region(), region(), region()
local plate = { GetName = function() return nil end, GetRegions = function() return glow, border, name end, GetChildren = function() return health, cast end }
ok(PT.PlateName(plate) == "PlaterTemucraftNamePlate1" and PT.PlateName(plate) == "PlaterTemucraftNamePlate1", "unnamed plate gets one stable name")
ok(PT.PlateName({ GetName = function() return "NamePlate5" end }) == "NamePlate5", "named plate keeps its name")
local proxy = PT.CreateBlizzardProxy(plate)
proxy:Hide()
ok(glow.a == 0 and name.a == 0 and health.a == 0 and cast.a == 0 and not proxy:IsShown(), "Hide makes every part invisible")
cast.a = 1
PT.KeepHidden(proxy)
ok(cast.a == 0, "KeepHidden hides a part the client showed again")
proxy:Show()
ok(border.a == 1 and health.a == 1 and proxy:IsShown(), "Show brings the plate back")
cast.a = 1 PT.KeepHidden(proxy)
ok(cast.a == 1, "KeepHidden does nothing while the 3.3.5 plate is shown")
ok(proxy:GetParent() == plate and tostring(proxy) ~= nil, "stand-in answers GetParent and tostring")

PT.SetCVar("nameplateMotion", 1)
PT.SetCVar("nameplateMaxDistance", 60)
PT.SetCVar("nameplateShowEnemies", true)
ok(sets[1] == "spreadnameplates=1" and sets[2] == "nameplateShowEnemies=1" and #sets == 2, "CVars: renamed, unknown skipped, booleans as 1/0")
ok(PT.GetCVar("nameplateMaxDistance") == "0" and PT.GetCVar("nameplateMotion") == "1" and PT.GetCVarBool("nameplateShowEnemies"), "GetCVar: unknown reads 0")
ok(PT.UnitPower("player", 4) == 3 and PT.UnitPowerMax("player", 4) == 5 and PT.UnitPower("player", 0) == 50, "combo points from GetComboPoints")
ok(PT.RealUnit("nameplate2") == "target" and PT.RealUnit("nameplate3") == "nameplate3", "real unit of a plate token")
PT.HookBinds(function() end)
local f = {} PT.WantPlateEvents(f)
ok(#bound == 1 and f.wanted, "bind callbacks and plate events reach the compat layer")
ok(PT.Modern == TemucraftCompat.Modern, "newer return values from compat")
print("all passed")

-- HD2 4.2 uses game time as a delayed-call ID. Two strikes in the same
-- tick can overwrite one another. Keep their schedules distinct and scoped
-- to the session and setup that created them; leave payloads/damage unchanged.
if _G.CNHD2DelayedCallsInstalled then return end
_G.CNHD2DelayedCallsInstalled = true

local add = DelayedCalls.Add
local serial = 0
function DelayedCalls:Add(id, delay, func)
	local hd2 = type(id) == "string" and (id:sub(1, 15) == "EagleAirstrike:" or id:sub(1, 21) == "HD2OffensiveRedTrail:")
	if not hd2 or type(func) ~= "function" then return add(self, id, delay, func) end
	serial = serial + 1
	local session = managers.network and managers.network:session()
	local current_setup = _G.setup
	return add(self, id .. ":CN:" .. tostring(serial), delay, function()
		local active = managers.network and managers.network:session()
		if not session or active ~= session or _G.setup ~= current_setup then return end
		return func()
	end)
end

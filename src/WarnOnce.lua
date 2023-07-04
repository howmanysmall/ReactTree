--!optimize 2
--!strict

local LuauPolyfill = require(script.Parent.Parent.LuauPolyfill)
local console = LuauPolyfill.console

local HasWarnedYet: {[string]: boolean} = {}

local function WarnOnce(name: string, message: string)
	if not HasWarnedYet[name] then
		HasWarnedYet[name] = true
		console.warn(message)
	end
end

return WarnOnce

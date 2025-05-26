-- Quebec entry point

local QuebecInstance = require(script.core.QuebecInstance)

local configurationTypes = script.types["config.d"]

local function loadConfiguration(): configurationTypes.TConfiguration
	if script.FindFirstChild("config") then
		return require(script.FindFirstChild("config"))
	else
		return {
			enabledModules = {},
		}
	end
end

return function()
	local config = loadConfiguration()
	local instance = QuebecInstance.new(config)

	instance:bootstrap()

	return instance
end

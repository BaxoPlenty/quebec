-- Quebec entry point

local QuebecInstance = require(script.core.QuebecInstance)

local configurationTypes = script.types["config.d"]

---Loads the framework configuration from the provided ModuleScript
---
---Note: This function uses `require` to load the ModuleScript
local function loadConfiguration(path: ModuleScript?): configurationTypes.FrameworkConfiguration
	if path then
		return require(path)
	else
		return require(script.config)
	end
end

return function(callingScript: BaseScript, configPath: ModuleScript?)
	local config = loadConfiguration(configPath)
	local instance = QuebecInstance.new(callingScript, config)

	instance:bootstrap()

	return instance
end

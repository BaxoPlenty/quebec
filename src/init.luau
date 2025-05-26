-- Quebec entry point

local QuebecInstance = require(script.core.QuebecInstance)

local configurationTypes = script.types["config.d"]

local function loadConfiguration(path: ModuleScript?): configurationTypes.TConfiguration
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

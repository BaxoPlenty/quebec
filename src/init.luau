-- Quebec entry point

local QuebecInstance = require(script.core.QuebecInstance)

local optionsTypes = script.types["options.d"]
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

return function(callingScript: BaseScript, opts: optionsTypes.InstanceOptions?)
	local config = if type(opts.config) == "table" then opts.config else loadConfiguration(opts.config)
	local instance = QuebecInstance.new(callingScript, config, opts)

	instance:bootstrap()

	return instance
end

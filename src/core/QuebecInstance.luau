local root = script.Parent.Parent

local logger = require(root.internal.logger)

local configurationTypes = script.Parent.Parent.types["config.d"]

type TQuebecInstance = {
	config: configurationTypes.TConfiguration,
	loadedModules: table,
}

local QuebecInstance: TQuebecInstance = {}

QuebecInstance.__index = QuebecInstance

function QuebecInstance.new(config)
	local self = setmetatable({}, QuebecInstance)

	self.config = config
    self.loadedModules = {}

	return self
end

function QuebecInstance:loadNecessaryModules()
	for _, moduleName in next, self.config.enabledModules do
		local module = script.Parent.Parent.modules.FindFirstChild(moduleName)

		if module then
			table.insert(self.loadedModules, require(module))
		else
			logger:warn("QuebecInstance:loadNecessaryModules", "expected to find module named %q, got none", moduleName)
		end
	end
end

function QuebecInstance:bootstrap()
	self:loadNecessaryModules()
end

return QuebecInstance

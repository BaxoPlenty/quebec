local RunService = game:GetService("RunService")
local root = script.Parent.Parent

local logger = require(root.internal.logger)
local serviceLoader = require(root.core.ServiceLoader)

local configurationTypes = root.types["config.d"]
local loaderTypes = root.types["loader.d"]

type TQuebecInstance = {
	callingScript: BaseScript,
	config: configurationTypes.TConfiguration,
	loadedModules: table,
	loader: loaderTypes.TLoader,
}

local QuebecInstance: TQuebecInstance = {}

QuebecInstance.__index = QuebecInstance

function QuebecInstance.new(callingScript, config)
	local self = setmetatable({}, QuebecInstance)

	self.callingScript = callingScript
	self.config = config
	self.loadedModules = {}

	return self
end

function QuebecInstance:loadNecessaryModules()
	for _, moduleName in next, self.config.enabledModules do
		local module = script.Parent.Parent.modules:FindFirstChild(moduleName)

		if module then
			table.insert(self.loadedModules, require(module))
		else
			logger:warn("QuebecInstance:loadNecessaryModules", "expected to find module named %q, got none", moduleName)
		end
	end
end

function QuebecInstance:bootstrap()
	self:loadNecessaryModules()

	if RunService:IsClient() then
        self.loader = serviceLoader.new(self.callingScript:FindFirstChild("controllers"))
	else
		self.loader = serviceLoader.new(self.callingScript:FindFirstChild("services"))
	end

    self.loader:load()
end

return QuebecInstance

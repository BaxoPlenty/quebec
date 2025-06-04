local RunService = game:GetService("RunService")

local root = script.Parent.Parent

local logger = require(root.internal.logger)
local serviceLoader = require(root.core.ServiceLoader)
local controllerLoader = require(root.core.ControllerLoader)

local configurationTypes = root.types["config.d"]
local loaderTypes = root.types["loader.d"]

export type QuebecInstance = {
	callingScript: BaseScript,
	config: configurationTypes.FrameworkConfiguration,
	loadedModules: table,
	loader: loaderTypes.Loader,
}

local QuebecInstance: QuebecInstance = {}

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
		-- TODO: Implement this to work with namespaces aswell
	end
end

function QuebecInstance:bootstrap()
	self:loadNecessaryModules()

	if RunService:IsClient() then
		self.loader = controllerLoader.new(self.callingScript:FindFirstChild("controllers"))
	else
		self.loader = serviceLoader.new(self, self.callingScript:FindFirstChild("services"))
	end

	if not self.loader:load() then
		logger:criticalError(
			"QuebecInstance:bootstrap",
			"(%s) unable to load modules. check the logs for more information",
			if RunService:IsClient() then "client" else "server"
		)
	end

	self.loader:run()
end

return QuebecInstance

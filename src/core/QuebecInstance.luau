local RunService = game:GetService("RunService")

local root = script.Parent.Parent

local logger = require(root.internal.logger)

local ServiceManager = require(root.core.ServiceManager)
local ControllerManager = require(root.core.ControllerManager)

local optionsTypes = root.types["options.d"]
local configurationTypes = root.types["config.d"]
local managerTypes = root.types["manager.d"]

export type QuebecInstance = {
	callingScript: BaseScript,
	config: configurationTypes.FrameworkConfiguration,
	instanceOptions: optionsTypes.InstanceOptions?,
	loadedModules: table,
	manager: managerTypes.Manager,
}

local QuebecInstance: QuebecInstance = {}

QuebecInstance.__index = QuebecInstance

function QuebecInstance.new(
	callingScript: BaseScript,
	config: configurationTypes.FrameworkConfiguration,
	instanceOptions: optionsTypes.InstanceOptions?
)
	local self = setmetatable({}, QuebecInstance)

	self.callingScript = callingScript
	self.instanceOptions = instanceOptions
	self.config = config
	self.loadedModules = {}

	return self
end

function QuebecInstance:bootstrap()
	if self.config.logging == "studio" then
		logger.enableDebug = game:GetService("RunService"):IsStudio()
	elseif self.config.logging == "always" then
		logger.enableDebug = true
	elseif self.config.logging == "never" then
		logger.enableDebug = false
	end

	if self.config.logNonCritical == true then
		logger.enableInfo = true
	else
		logger.enableInfo = false
	end

	logger:debug(
		"QuebecInstance:bootstrap",
		"(%s) logger setup finished debug=%s info=%s",
		if RunService:IsClient() then "client" else "server",
		tostring(logger.enableDebug),
		tostring(logger.enableInfo)
	)

	logger:debug(
		"QuebecInstance:bootstrap",
		"(%s) initializing manager",
		if RunService:IsClient() then "client" else "server"
	)

	if RunService:IsClient() then
		self.manager = ControllerManager.new(self.callingScript:FindFirstChild("controllers"))
	else
		self.manager = ServiceManager.new(self, self.callingScript:FindFirstChild("services"))
	end

	if not self.manager:load() then
		logger:criticalError(
			"QuebecInstance:bootstrap",
			"(%s) unable to load modules. check the logs for more information",
			if RunService:IsClient() then "client" else "server"
		)
	end

	self.manager:run()

	if self.instanceOptions.exportName ~= nil then
		logger:warn(
			"QuebecInstance:bootstrap",
			"(%s) todo: enable export exportName=%q",
			if RunService:IsClient() then "client" else "server",
			self.instanceOptions.exportName
		)
	end
end

return QuebecInstance

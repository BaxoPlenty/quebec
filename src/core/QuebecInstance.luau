local RunService = game:GetService("RunService")

local root = script.Parent.Parent

local logger = require(root.internal.logger)

local SingletonManager = require(root.core.SingletonManager)
local DependencyResolver = require(root.core.DependencyResolver)
local DefaultConfig = require(root.config)

local optionsTypes = root.types["options.d"]
local configurationTypes = root.types["config.d"]
local managerTypes = root.types["manager.d"]
local resolverTypes = root.types["resolver.d"]

export type QuebecInstance = {
	callingScript: BaseScript,
	config: configurationTypes.FrameworkConfiguration,
	instanceOptions: optionsTypes.InstanceOptions?,
	loadedModules: table,
	singletonFolder: Folder,
	manager: managerTypes.Manager<any>,
	resolver: resolverTypes.Resolver,

	waitForSharedInstance: (QuebecInstance, name: string, timeout: number?) -> QuebecInstance?,
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

	local singletonFolderName = type(instanceOptions.singletonFolder) == "string" and instanceOptions.singletonFolder
		or (if RunService:IsClient() then "controllers" else "services")

	if typeof(instanceOptions.singletonFolder) == "Instance" then
		self.singletonFolder = instanceOptions.singletonFolder
	else
		self.singletonFolder = self.callingScript:FindFirstChild(singletonFolderName)
			or self.callingScript.Parent:FindFirstChild(singletonFolderName)
	end

	if not self.singletonFolder then
		logger:criticalError("QuebecInstance.new", "unable to find singletonFolder")
	end

	self.resolver = DependencyResolver.new(self)

	return self
end

function QuebecInstance:waitForSharedInstance(instanceName: string, timeout: number?): QuebecInstance?
	local start = os.clock()

	timeout = timeout or 5

	while true do
		local instance = shared.SharedQuebecInstances and shared.SharedQuebecInstances[instanceName]

		if instance then
			return instance
		end

		if os.clock() - start > timeout then
			logger:warn(
				"QuebecInstance:waitForSharedInstance",
				"shared QuebecInstance %q not found within %d seconds",
				instanceName,
				timeout
			)

			return nil
		end

		task.wait(0.25)
	end
end

function QuebecInstance:reconcileConfig()
	if self.config.debug == nil then
		self.config.debug = DefaultConfig.debug
	end

	if self.config.logNonCritical == nil then
		self.config.logNonCritical = DefaultConfig.logNonCritical
	end
end

function QuebecInstance:bootstrap()
	self:reconcileConfig()

	if self.config.debug == "studio" then
		logger.enableDebug = game:GetService("RunService"):IsStudio()
	elseif self.config.debug == "always" then
		logger.enableDebug = true
	elseif self.config.debug == "never" then
		logger.enableDebug = false
	end

	if self.config.logNonCritical == true then
		logger.enableInfo = true
	else
		logger.enableInfo = false
	end

	logger:debug(
		"QuebecInstance:bootstrap",
		"logger setup finished debug=%s info=%s",
		tostring(logger.enableDebug),
		tostring(logger.enableInfo)
	)

	logger:debug("QuebecInstance:bootstrap", "initializing manager")

	self.manager = SingletonManager.new(self, self.singletonFolder)

	if not self.manager:load() then
		logger:criticalError("QuebecInstance:bootstrap", "unable to load modules. check the logs for more information")
	end

	self.manager:run()

	if self.instanceOptions.exportName ~= nil then
		if not shared.SharedQuebecInstances then
			shared.SharedQuebecInstances = {}
		end

		if shared.SharedQuebecInstances[self.instanceOptions.exportName] then
			logger:criticalError(
				"QuebecInstance:bootstrap",
				"an instance named %q was already exported before",
				self.instanceOptions.exportName
			)
		end

		shared.SharedQuebecInstances[self.instanceOptions.exportName] = self
	end
end

return QuebecInstance

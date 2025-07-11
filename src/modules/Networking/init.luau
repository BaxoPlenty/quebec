local FolderName = "__QBC_EV"

local RunService = game:GetService("RunService")

local Logger = require(script.Parent.Parent.internal.logger)

local event = require(script.event)
local eventTypes = require(script.event.types)

local func = require(script.func)
local funcTypes = require(script.func.types)

-- Re-export some types for quick access

export type Event<Args...> = eventTypes.Event<Args...>
export type Func<Args..., Returns...> = funcTypes.Func<Args..., Returns...>

-- Custom types

export type UntypedEvent = Event<...any>
export type UntypedFunc = Func<...any, ...any>

local Networking = {}

local NetworkingFolder = (function()
	if RunService:IsClient() then
		return script:WaitForChild(FolderName)
	else
		local folder = script:FindFirstChild(FolderName)

		if folder == nil then
			folder = Instance.new("Folder")

			folder.Name = FolderName
			folder.Parent = script
		end

		return folder
	end
end)() :: Folder

function Networking.event(name: string): UntypedEvent
	local instance = nil

	if RunService:IsClient() then
		instance = NetworkingFolder:WaitForChild(name)
	else
		instance = NetworkingFolder:FindFirstChild(name)

		if not instance then
			instance = Instance.new("RemoteEvent")

			instance.Name = name
			instance.Parent = NetworkingFolder
		end
	end

	if not instance then
		Logger.critical("unable to setup event %q, instance not created nor found", name)
	end

	return event(instance) :: UntypedEvent
end

function Networking.func(name: string): UntypedFunc
	local instance = nil

	if RunService:IsClient() then
		instance = NetworkingFolder:WaitForChild(name)
	else
		instance = NetworkingFolder:FindFirstChild(name)

		if not instance then
			instance = Instance.new("RemoteFunction")

			instance.Name = name
			instance.Parent = NetworkingFolder
		end
	end

	if not instance then
		Logger.critical("unable to setup function %q, instance not created nor found", name)
	end

	return func(instance) :: UntypedFunc
end

return Networking

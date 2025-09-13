--!strict

local FolderName = "__QBC_EV"

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Logger = require(script.Parent.Parent.internal.logger)

local event = require(script.event)
local eventTypes = require(script.event.types)

local unreliable = require(script.unreliable)
local unreliableTypes = require(script.unreliable.types)

local func = require(script.func)
local funcTypes = require(script.func.types)

-- Re-export some types for quick access

export type Event<Args...> = eventTypes.Event<Args...>
export type Unreliable<Args...> = unreliableTypes.Unreliable<Args...>
export type Func<Args..., Returns...> = funcTypes.Func<Args..., Returns...>

-- Custom types

export type UntypedEvent = Event<...any>
export type UntypedUnreliable = Unreliable<...any>
export type UntypedFunc = Func<...any, ...any>

local Networking = {}

local NetworkingFolder = (function()
	if RunService:IsClient() then
		local folder = script:WaitForChild(FolderName, 5)

		if not folder then
			Logger.warn("unable to find networking folder. did you forget to handle the events on the server?")
			Logger.warn("creating client-sided networking folder")

			folder = Instance.new("Folder")

			folder.Name = FolderName
			folder.Parent = script
		end

		return folder
	else
		local folder = script:FindFirstChild(FolderName)

		if folder == nil then
			folder = Instance.new("Folder")

			folder.Name = FolderName
			folder.Parent = script
		end

		return folder :: Folder
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

	return event(instance :: RemoteEvent) :: UntypedEvent
end

function Networking.anonymousEvent(): UntypedEvent
	return Networking.event(HttpService:GenerateGUID())
end

function Networking.unreliable(name: string): UntypedUnreliable
	local instance = nil

	if RunService:IsClient() then
		instance = NetworkingFolder:WaitForChild(name)
	else
		instance = NetworkingFolder:FindFirstChild(name)

		if not instance then
			instance = Instance.new("UnreliableRemoteEvent")

			instance.Name = name
			instance.Parent = NetworkingFolder
		end
	end

	if not instance then
		Logger.critical("unable to setup unreliable %q, instance not created nor found", name)
	end

	return unreliable(instance :: UnreliableRemoteEvent) :: UntypedUnreliable
end

function Networking.anonymousUnreliable(): UntypedUnreliable
	return Networking.unreliable(HttpService:GenerateGUID())
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

	return func(instance :: RemoteFunction) :: UntypedFunc
end

function Networking.anonymousFunc(): UntypedFunc
	return Networking.func(HttpService:GenerateGUID())
end

return Networking

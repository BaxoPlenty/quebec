local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

export type Signal<Args...> = {
	instance: BindableEvent,

	fire: (self: Signal<Args...>, Args...) -> (),
	connect: (self: Signal<Args...>, callback: (Args...) -> ()) -> RBXScriptConnection,
}

local Folder = (function()
	local parent = script

	if RunService:IsServer() then
		parent = ServerStorage
	end

	local instance = Instance.new("Folder")

	instance.Name = HttpService:GenerateGUID()
	instance.Parent = parent

	return instance
end)()

local Signal = {}

Signal.__index = Signal

function Signal.new<Args...>(name: string): Signal<Args...>
	local self = (setmetatable({}, Signal) :: any) :: Signal<Args...>

	local instance = Folder:FindFirstChild(name)

	if not instance then
		instance = Instance.new("BindableEvent")

		instance.Name = name
		instance.Parent = Folder
	end

	self.instance = instance

	return self
end

function Signal.fire<Args...>(self: Signal<Args...>, ...: Args...)
	self.instance:Fire(...)
end

function Signal.connect<Args...>(self: Signal<Args...>, callback: (Args...) -> ())
	return self.instance.Event:Connect(callback)
end

return Signal

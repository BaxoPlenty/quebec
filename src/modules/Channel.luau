local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

export type Channel<Args..., Returns...> = {
	instance: BindableFunction,

	invoke: (self: Channel<Args..., Returns...>, Args...) -> Returns...,
	set: (self: Channel<Args..., Returns...>, callback: (Args...) -> Returns...) -> (),
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

local Channel = {}

Channel.__index = Channel

function Channel.new<Args..., Returns...>(name: string): Channel<Args..., Returns...>
	local self = (setmetatable({}, Channel) :: any) :: Channel<Args...>

	local instance = Folder:FindFirstChild(name)

	if not instance then
		instance = Instance.new("BindableFunction")

		instance.Name = name
		instance.Parent = Folder
	end

	self.instance = instance

	return self
end

function Channel.invoke<Args..., Returns...>(self: Channel<Args...>, ...: Args...): Returns...
	return self.instance:Invoke(...)
end

function Channel.set<Args..., Returns...>(self: Channel<Args...>, callback: (Args...) -> ())
	self.instance.OnInvoke = callback
end

return Channel

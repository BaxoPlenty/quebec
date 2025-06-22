local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local root = script.Parent.Parent

local logger = require(root.internal.logger)

local Networking = {}

function Networking:initClient()
	local folder = ReplicatedStorage:WaitForChild("QBCN", 5) -- todo: add customization for this

	if not folder then
		logger:criticalError("Networking:initClient", "unable to find networking folder %q", "QBCN")
	end

	self.folder = folder
end

function Networking:initServer()
	local folder = ReplicatedStorage:FindFirstChild("QBCN")

	if not folder then
		folder = Instance.new("Folder")

		folder.Name = "QBCN"
		folder.Parent = ReplicatedStorage
	end

	self.folder = folder
end

function Networking:init()
	if RunService:IsClient() then
		self:initClient()
	else
		self:initServer()
	end
end

function Networking:getEvent(eventName: string): RemoteEvent
	if RunService:IsClient() then
		local event = self.folder:WaitForChild(eventName, 5)

		if not event then
			logger:criticalError("Networking:getEvent", "unable to find network event %q", eventName)
		end

		return event
	else
		local event = self.folder:FindFirstChild(eventName)

		if not event then
			event = Instance.new("RemoteEvent")

			event.Name = eventName
			event.Parent = self.folder
		end

		return event
	end
end

function Networking:declare(event: string | { string })
	if RunService:IsServer() then
		if type(event) == "table" then
			for _, v in next, event do
				self:getEvent(v)
			end
		else
			self:getEvent(event)
		end
	end
end

function Networking:connect(eventName: string, callback: (...any) -> any): RBXScriptConnection
	local event = self:getEvent(eventName)

	if RunService:IsClient() then
		return event.OnClientEvent:Connect(callback)
	else
		return event.OnServerEvent:Connect(callback)
	end
end

function Networking:once(eventName: string, callback: (...any) -> any): RBXScriptConnection
	local event = self:getEvent(eventName)

	if RunService:IsClient() then
		return event.OnClientEvent:Once(callback)
	else
		return event.OnServerEvent:Once(callback)
	end
end

function Networking:fire(...)
	local arguments = { ... }

	if RunService:IsClient() then
		if #arguments < 1 then
			logger:criticalError("Networking:fire", "eventName is missing")
		end

		local eventName = table.remove(arguments, 1)
		local eventArgs = arguments

		local event = self:getEvent(eventName)

		event:FireServer(table.unpack(eventArgs))
	else
		if #arguments < 2 then
			logger:criticalError("Networking:fire", "eventName and/or target is missing")
		end

		local eventName = table.remove(arguments, 1)
		local target = table.remove(arguments, 1)
		local eventArgs = arguments

		local event = self:getEvent(eventName)

		if type(target) == "userdata" and target.IsA and target:IsA("Player") then
			event:FireClient(target, table.unpack(eventArgs))
		elseif type(target) == "table" then
			for _, player in next, target do
				event:FireClient(player, table.unpack(eventArgs))
			end
		end
	end
end

function Networking:broadcast(eventName: string, ...)
	if RunService:IsClient() then
		return logger:error("Networking:broadcast", "unable to broadcast from client")
	end

	local event = self:getEvent(eventName)

	event:FireAllClients(...)
end

function Networking:except(eventName: string, target: Player | { Player }, ...)
	if RunService:IsClient() then
		return logger:error("Networking:except", "unable to call except from client")
	end

	local event = self:getEvent(eventName)

	target = if type(target) == "userdata" then { target } else target

	if #target == 0 then
		return self:broadcast(eventName, ...)
	end

	for _, player in Players:GetPlayers() do
		if table.find(target, player) then
			continue
		end

		event:FireClient(player, ...)
	end
end

return Networking

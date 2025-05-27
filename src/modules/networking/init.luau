local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local root = script.Parent.Parent

local logger = require(root.internal.logger)

local Networking = {
	folder = nil,
}

function Networking:setup()
	if RunService:IsServer() then
		self.folder = Instance.new("Folder")

		self.folder.Name = "QBC_NETWORKING"
		self.folder.Parent = ReplicatedStorage
	else
		self.folder = ReplicatedStorage:WaitForChild("QBC_NETWORKING", 16)
	end

	if not self.folder then
		logger:criticalError(
			`Networking:setup {RunService:IsClient() and "(client)" or "(server)"}`,
			"error while waiting for or creating networking folder"
		)
	end
end

function Networking:bindEvent(eventName: string, callback: (...any) -> nil)
	local event = self.folder:FindFirstChild(eventName)

	if RunService:IsServer() then
		if not event then
			event = Instance.new("RemoteEvent")

			event.Name = eventName
			event.Parent = self.folder
		end

		event.OnServerEvent:Connect(callback)
	else
		if not event then
			event = self.folder:WaitForChild(eventName, 6)

			if not event then
				logger:criticalError(
					"Networking:bindEvent (client)",
					"unable to find remote even after waiting 6 seconds"
				)
			end
		end

		event.OnClientEvent:Connect(callback)
	end
end

export type NetworkingDependency = typeof(Networking)

return Networking

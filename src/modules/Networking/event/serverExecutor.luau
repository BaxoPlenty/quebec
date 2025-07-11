local Players = game:GetService("Players")

local types = require(script.Parent.types)

local ExecutorMethods = {}

ExecutorMethods.__index = ExecutorMethods

function ExecutorMethods.fire<Args...>(self: types.ServerExecutor<Args...>, player: Player | { Player }, ...: Args...)
	if type(player) == "table" then
		for _, p in player do
			self.instance:FireClient(p, ...)
		end
	else
		self.instance:FireClient(player, ...)
	end
end

function ExecutorMethods.broadcast<Args...>(self: types.ServerExecutor<Args...>, ...: Args...)
	self.instance:FireAllClients(...)
end

function ExecutorMethods.except<Args...>(self: types.ServerExecutor<Args...>, player: Player | { Player }, ...: Args...)
	local playersToFireTo = {}

	if type(player) == "table" then
		for _, p in Players:GetPlayers() do
			if not table.find(player, p) then
				table.insert(playersToFireTo, p)
			end
		end
	else
		for _, p in Players:GetPlayers() do
			if p ~= player then
				table.insert(playersToFireTo, p)
			end
		end
	end

	self:fire(playersToFireTo, ...)
end

function ExecutorMethods.connect<Args...>(self: types.ServerExecutor<Args...>, callback: (player: Player, Args...) -> ())
	return self.instance.OnServerEvent:Connect(callback)
end

return function<Args...>(self: types.Event<Args...>): types.ServerExecutor<Args...>
	return setmetatable({
		instance = self.instance,
	}, ExecutorMethods) :: any
end

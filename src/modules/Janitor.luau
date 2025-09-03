local Logger = require(script.Parent.Parent.internal.logger)

export type Janitor = {
	connections: { RBXScriptConnection },
	threads: { thread },
	cleanupFunctions: { () -> () },
}

local Janitor = {}

Janitor.__index = Janitor

function Janitor.new(): Janitor
	local self = (setmetatable({}, Janitor) :: any) :: Janitor

	self.connections = {}
	self.threads = {}
	self.cleanupFunctions = {}

	return self
end

function Janitor.add(self: Janitor, v: thread | RBXScriptConnection | () -> ())
	if typeof(v) == "thread" then
		table.insert(self.threads, v)
	elseif typeof(v) == "function" then
		table.insert(self.cleanupFunctions, v)
	elseif typeof(v) == "RBXScriptConnection" then
		table.insert(self.connections, v)
	else
		Logger.warn("attempt to add value of type %q to janitor", typeof(v))
	end
end

function Janitor.cleanup(self: Janitor)
	for _, v in self.cleanupFunctions do
		v()
	end

	table.clear(self.cleanupFunctions)

	for _, t in self.threads do
		task.cancel(t)
	end

	table.clear(self.threads)

	for _, connection in self.connections do
		connection:Disconnect()
	end

	table.clear(self.connections)
end

return Janitor

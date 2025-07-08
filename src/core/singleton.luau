local root = script.Parent.Parent

local Types = require(root.types)
local Registry = require(root.internal.registry)

-- todo: add setmetatable and listen to __newindex for lifecycle definition, etc.
return function<T>(singleton: Types.AsSingleton<T>): T
	local internal = singleton :: Types.AsInternalSingleton<T>

	Registry.addSingleton(internal)

	return singleton :: any
end

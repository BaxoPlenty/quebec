local root = script.Parent.Parent

local Registry = require(root.internal.registry)

return function(singleton)
	Registry.addSingleton(singleton)

	return singleton
end

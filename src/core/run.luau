local root = script.Parent.Parent

local Registry = require(root.internal.registry)

return function()
	Registry.initialize()
end

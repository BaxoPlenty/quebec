local root = script.Parent.Parent

local Types = require(root.types)
local Registry = require(root.internal.registry)

local function getCustomLifecycle(k, v): (boolean, Types.InternalLifecycle?, string?)
	local lifecycle = nil :: Types.InternalLifecycle
	local methodName = nil :: string

	if typeof(k) == "table" and k.__type == "Quebec.Lifecycle" then
		lifecycle = k
		methodName = v
	elseif typeof(v) == "table" and v.__type == "Quebec.Lifecycle" then
		lifecycle = v :: Types.InternalLifecycle

		methodName = lifecycle.defaultMethod
	else
		return false
	end

	return true, lifecycle, methodName
end

return function<T>(singleton: Types.AsSingleton<T>): T
	local internal = singleton :: Types.AsInternalSingleton<T>

	Registry.addSingleton(internal)

	for k, v in internal.lifecycles do
		local isCustom, lifecycle, methodName = getCustomLifecycle(k, v)
		
		if not isCustom then
			continue
		end

		table.insert(lifecycle.__singletons, {
			singleton = singleton,
			fn = methodName,
		})

		if not lifecycle.__registered then
			lifecycle.__registered = true

			Registry.addCustomLifecycle(lifecycle)
		end
	end

	return singleton :: any
end

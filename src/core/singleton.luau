local root = script.Parent.Parent

local Types = require(root.types)
local Registry = require(root.internal.registry)

return function<T>(singleton: Types.AsSingleton<T>): T
	local internal = singleton :: Types.AsInternalSingleton<T>

	Registry.addSingleton(internal)

	if internal.init and type(internal.init) == "function" then
		internal:init()
	end

	local startLifecycleMethod = if table.find(internal.lifecycles, "start")
		then "start"
		else internal.lifecycles["start"]

	if startLifecycleMethod and Registry.isLateStartEnabled() then
		task.spawn(function()
			internal[startLifecycleMethod](internal)
		end)
	end

	return singleton :: any
end

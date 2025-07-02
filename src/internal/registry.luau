local Registry = {
	singletons = nil,
	data = nil,
}

function Registry.initialize()
	shared.__QuebecInternalData = {
		singletons = {},
	}

	Registry.data = shared.__QuebecInternalData
	Registry.singletons = Registry.data.singletons
end

function Registry.addSingleton(singleton)
	if singleton.__registered then
		return
	end

	singleton.__registered = true

	table.insert(Registry.singletons, singleton)
end

return Registry

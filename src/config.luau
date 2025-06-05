local configurationTypes = script.Parent.types["config.d"]

local defaultConfiguration: configurationTypes.FrameworkConfiguration = {
	--[[ - START OF CONFIG - ]]

	logging = "studio",

	--[[ - END OF CONFIG - ]]
}

return defaultConfiguration

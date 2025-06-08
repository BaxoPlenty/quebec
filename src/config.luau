local configurationTypes = script.Parent.types["config.d"]

local defaultConfiguration: configurationTypes.FrameworkConfiguration = {
	--[[ - START OF CONFIG - ]]

	debug = "never",
	logNonCritical = false,

	--[[ - END OF CONFIG - ]]
}

return defaultConfiguration

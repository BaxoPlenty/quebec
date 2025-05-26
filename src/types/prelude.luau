local root = script.Parent

return {
	configurationTypes = root["config.d"],
	serviceTypes = root["service.d"],
	controllerTypes = root["controller.d"],
}

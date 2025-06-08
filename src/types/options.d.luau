local frameworkTypes = script.Parent["config.d"]

export type InstanceOptions = {
	config: (ModuleScript | frameworkTypes.FrameworkConfiguration)?,
	exportName: string?,
	singletonFolder: (string | Folder)?,
}

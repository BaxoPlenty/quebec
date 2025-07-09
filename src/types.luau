-- Configuration

export type FrameworkConfiguration = {
	--- A table defining how many instances are there.
	--- It's only required if you have more than one instance.
	instances: { string }?,

	--- Defaults to false in production, but true in Studio. Enabling this will enable debug prints.
	debug: boolean?,

	--- Defaults to true. Enabling this will enable info prints.
	info: boolean?,
}

-- Singleton

export type Lifecycle = "start" | "stop" | "onTick" | "onPhysics" | "onRender"

--- Type defining a Quebec singleton.
export type Singleton = {
	--- Singleton-specific data. Quebec will never access this field.
	data: any?,

	--- Optional lifecycle definitions of thae singleton. These are required if you want to use a lifecycle.
	lifecycles: { [string | number]: string }?,

	--- Optional method used to do early setup when nothing is running.
	init: ((self: Singleton) -> unknown)?,
}

--- Type reserved for internal fields.
export type InternalSingleton = {}

export type AsSingleton<T> = T & Singleton

export type AsInternalSingleton<T> = AsSingleton<T> & InternalSingleton

return {}

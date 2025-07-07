-- Configuration

export type FrameworkConfiguration = {}

-- Singleton

export type Lifecycle = "start" | "stop" | "onTick" | "onStep" | "onPhysics"

--- Type defining a Quebec singleton.
export type Singleton = {
	--- Singleton-specific data. Quebec will never access this field.
	data: any?,

	--- Optional lifecycle definitions of thae singleton. These are required if you want to use a lifecycle.
	lifecycles: { [Lifecycle | number]: Lifecycle | string }?,

	--- Optional method used to do early setup when nothing is running.
	init: ((self: Singleton) -> unknown)?,
}

--- Type reserved for internal fields.
export type InternalSingleton = {}

export type AsSingleton<T> = T & Singleton

export type AsInternalSingleton<T> = AsSingleton<T> & InternalSingleton

return {}

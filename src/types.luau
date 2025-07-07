-- Configuration

export type FrameworkConfiguration = {}

-- Singleton

export type Lifecycle = "start" | "stop" | "onTick" | "onStep" | "onPhysics"

--- Type defining a Quebec singleton.
export type Singleton = {
	--- Singleton-specific data. Quebec will never access this field.
	data: any?,

	--- Lifecycle definitions of the singleton.
	lifecycles: { [Lifecycle | number]: Lifecycle | string }?,

	--- Optional method used to do early setup when nothing is running.
	init: ((self: Singleton) -> unknown)?,
}

--- Type reserved for internal fields.
export type InternalSingleton = {}

export type AsSingleton<T> = T & Singleton

export type AsInternalSingleton<T> = AsSingleton<T> & InternalSingleton

return {}

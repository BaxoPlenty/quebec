-- Configuration

export type FrameworkConfiguration = {
	--- A table defining how many instances are there.
	--- It's only required if you have more than one instance.
	instances: { string }?,

	--- Defaults to false in production, but true in studio. Enabling this will enable debug prints.
	debug: boolean?,

	--- Defaults to true. Enabling this will enable info prints.
	info: boolean?,
}

-- Custom Lifecycle

export type CustomLifecycleData = {
	--- The default method name of the lifecycle.
	defaultMethod: string,
}

export type CustomLifecycle<Data> = Data & {
	--- Returns a list of all singleton entries that have attached to this lifecycle.
	getSingletons: (self: CustomLifecycle<Data>) -> { { singleton: Singleton, fn: string } },

	--- Invokes the current lifecycle on all registered singletons in a new thread with the provided arguments.
	invokeAll: (self: CustomLifecycle<Data>, ...any) -> (),

	--- Invokes the current lifecycle on all registered singletons with the provided arguments.
	---
	--- Note: This function will yield, because it does not utilize `task.spawn` like `invokeAll` does.
	invokeAllSameThread: (self: CustomLifecycle<Data>, ...any) -> (),

	run: ((self: CustomLifecycle<Data>) -> unknown)?,
	onSingletonAdded: ((self: CustomLifecycle<Data>, singleton: Singleton) -> unknown)?,
}

export type InternalLifecycle = CustomLifecycle<CustomLifecycleData & {
	__singletons: { { singleton: Singleton, fn: string } },
	__registered: boolean?,
}>

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

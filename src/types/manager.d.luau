export type Manager<T> = {
	loadedSingletons: { T },

	load: (Manager<T>) -> boolean,
	run: (Manager<T>) -> nil,
	callLifecycle: (Manager<T>, T, string, ...any) -> any,
}

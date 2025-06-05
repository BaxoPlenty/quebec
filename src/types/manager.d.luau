export type Manager = {
	load: (Manager) -> boolean,
	run: (Manager) -> nil,
	callLifecycle: (Manager, any, string, ...any) -> any,
}

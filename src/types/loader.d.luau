export type Loader = {
	load: (Loader) -> boolean,
	run: (Loader) -> nil,
}

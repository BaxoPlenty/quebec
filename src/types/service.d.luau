export type TService = {
	data: any?,
	identifier: string?,
	dependencies: { [number | string]: string | ModuleScript }?,

	onStart: (TService) -> nil?,
}

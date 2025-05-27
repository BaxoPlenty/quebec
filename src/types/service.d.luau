export type TService = {
	data: any?,
	identifier: string?,
	dependencies: { [number | string]: string | ModuleScript }?,

	onStart: ((self: TService) -> nil)?,
}

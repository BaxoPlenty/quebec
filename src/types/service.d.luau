export type Service = {
	data: any?,
	identifier: string?,
	dependencies: { [number | string]: string | ModuleScript }?,

	onStart: ((Service) -> nil)?,
}

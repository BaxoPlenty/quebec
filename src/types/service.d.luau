export type Service = {
	data: any?,
	identifier: string?,
	dependencies: { [number | string]: string | ModuleScript }?,

	onStart: ((self: Service) -> nil)?,
}

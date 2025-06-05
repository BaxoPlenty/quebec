export type Service = {
	data: any?,
	identifier: string?,
	dependencies: { [number | string]: string | ModuleScript }?,
	lifecycles: { [string | number]: string }?,
}

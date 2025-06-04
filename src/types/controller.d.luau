export type Controller = {
	data: any?,
	identifier: string?,
	dependencies: { [number | string]: string | ModuleScript }?,

    onStart: ((Controller) -> nil)?,
}

export type BaseFunc = {
	instance: RemoteFunction,
}

export type Func<Args..., Returns...> = BaseFunc & {
	client: (self: Func<Args..., Returns...>) -> ClientExecutor<Args..., Returns...>,
	server: (self: Func<Args..., Returns...>) -> ServerExecutor<Args..., Returns...>,
}

export type ClientExecutor<Args..., Returns...> = BaseFunc & {
	invoke: (self: ClientExecutor<Args..., Returns...>, Args...) -> Returns...,
	connect: (self: ClientExecutor<Args..., Returns...>, callback: (Args...) -> Returns...) -> (),
}

export type ServerExecutor<Args..., Returns...> = BaseFunc & {
	invoke: (self: ServerExecutor<Args..., Returns...>, player: Player, Args...) -> Returns...,
	connect: (self: ServerExecutor<Args..., Returns...>, callback: (player: Player, Args...) -> Returns...) -> (),
}

return {}

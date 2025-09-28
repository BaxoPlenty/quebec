export type BaseFunc = {
	instance: RemoteFunction,
}

export type Func<Args..., Returns...> = FuncTwoWay<Args..., Returns..., Args..., Returns...>

export type FuncTwoWay<SArgs..., SReturns..., CArgs..., CReturns...> = BaseFunc & {
	client: (self: any) -> ClientExecutor<CArgs..., CReturns...>,
	server: (self: any) -> ServerExecutor<SArgs..., SReturns...>,
}

export type ClientExecutor<CArgs..., CReturns...> = BaseFunc & {
	invoke: (self: ClientExecutor<CArgs..., CReturns...>, CArgs...) -> CReturns...,
	connect: (self: ClientExecutor<CArgs..., CReturns...>, callback: (CArgs...) -> CReturns...) -> (),
}

export type ServerExecutor<SArgs..., SReturns...> = BaseFunc & {
	invoke: (self: ServerExecutor<SArgs..., SReturns...>, player: Player, SArgs...) -> SReturns...,
	connect: (self: ServerExecutor<SArgs..., SReturns...>, callback: (player: Player, SArgs...) -> SReturns...) -> (),
}

return {}

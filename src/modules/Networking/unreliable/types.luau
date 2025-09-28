--!strict

export type BaseUnreliable = {
	instance: UnreliableRemoteEvent,
}

export type Unreliable<Args...> = UnreliableTwoWay<Args..., Args...>

export type UnreliableTwoWay<SArgs..., CArgs...> = BaseUnreliable & {
	client: (self: any) -> ClientExecutor<CArgs...>,
	server: (self: any) -> ServerExecutor<SArgs...>
}

export type ClientExecutor<CArgs...> = BaseUnreliable & {
	fire: (self: ClientExecutor<CArgs...>, CArgs...) -> (),
	connect: (self: ClientExecutor<CArgs...>, callback: (CArgs...) -> ()) -> RBXScriptConnection,
}

export type ServerExecutor<SArgs...> = BaseUnreliable & {
	fire: (self: ServerExecutor<SArgs...>, player: Player | { Player }, SArgs...) -> (),
	broadcast: (self: ServerExecutor<SArgs...>, SArgs...) -> (),
	except: (self: ServerExecutor<SArgs...>, player: Player | { Player }, SArgs...) -> (),

	connect: (self: ServerExecutor<SArgs...>, callback: (player: Player, SArgs...) -> ()) -> RBXScriptConnection,
}

return {}

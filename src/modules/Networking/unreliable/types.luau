export type BaseUnreliable = {
	instance: UnreliableRemoteEvent,
}

export type Unreliable<Args...> = BaseUnreliable & {
	client: (self: Unreliable<Args...>) -> ClientExecutor<Args...>,
	server: (self: Unreliable<Args...>) -> ServerExecutor<Args...>,
}

export type ClientExecutor<Args...> = BaseUnreliable & {
	fire: (self: ClientExecutor<Args...>, Args...) -> (),
	connect: (self: ClientExecutor<Args...>, callback: (Args...) -> ()) -> RBXScriptConnection,
}

export type ServerExecutor<Args...> = BaseUnreliable & {
	fire: (self: ServerExecutor<Args...>, player: Player | { Player }, Args...) -> (),
	broadcast: (self: ServerExecutor<Args...>, Args...) -> (),
	except: (self: ServerExecutor<Args...>, player: Player | { Player }, Args...) -> (),

	connect: (self: ServerExecutor<Args...>, callback: (player: Player, Args...) -> ()) -> RBXScriptConnection,
}

return {}

export type BaseEvent = {
	instance: RemoteEvent,
}

export type Event<Args...> = BaseEvent & {
	client: (self: Event<Args...>) -> ClientExecutor<Args...>,
	server: (self: Event<Args...>) -> ServerExecutor<Args...>,
}

export type ClientExecutor<Args...> = BaseEvent & {
	fire: (self: ClientExecutor<Args...>, Args...) -> (),
	connect: (self: ClientExecutor<Args...>, callback: (Args...) -> ()) -> RBXScriptConnection,
}

export type ServerExecutor<Args...> = BaseEvent & {
	fire: (self: ServerExecutor<Args...>, player: Player | { Player }, Args...) -> (),
	broadcast: (self: ServerExecutor<Args...>, Args...) -> (),
	except: (self: ServerExecutor<Args...>, player: Player | { Player }, Args...) -> (),

	connect: (self: ServerExecutor<Args...>, callback: (player: Player, Args...) -> ()) -> RBXScriptConnection,
}

return {}

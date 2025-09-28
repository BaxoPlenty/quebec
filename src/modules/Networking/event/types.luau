export type BaseEvent = {
	instance: RemoteEvent,
}

export type Event<Args...> = EventTwoWay<Args..., Args...>

export type EventTwoWay<SArgs..., CArgs...> = BaseEvent & {
	client: (self: any) -> ClientExecutor<CArgs...>,
	server: (self: any) -> ServerExecutor<SArgs...>,
}

export type ClientExecutor<CArgs...> = BaseEvent & {
	fire: (self: ClientExecutor<CArgs...>, CArgs...) -> (),
	connect: (self: ClientExecutor<CArgs...>, callback: (CArgs...) -> ()) -> RBXScriptConnection,
}

export type ServerExecutor<SArgs...> = BaseEvent & {
	fire: (self: ServerExecutor<SArgs...>, player: Player | { Player }, SArgs...) -> (),
	broadcast: (self: ServerExecutor<SArgs...>, SArgs...) -> (),
	except: (self: ServerExecutor<SArgs...>, player: Player | { Player }, SArgs...) -> (),

	connect: (self: ServerExecutor<SArgs...>, callback: (player: Player, SArgs...) -> ()) -> RBXScriptConnection,
}

return {}

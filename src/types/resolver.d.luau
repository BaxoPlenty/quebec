export type ResolverResult = {
	instanceName: string?,
	pathSegments: { string },
	kind: "module" | "singleton",
}

export type Resolver = {
	resolve: (Resolver, searchString: string) -> ResolverResult?,
}

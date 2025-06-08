export type FinderResult = {
	instanceName: string?,
	pathSegments: { string },
	kind: "module" | "singleton",
}

export type Finder = {
	find: (Finder, searchString: string) -> FinderResult?,
}

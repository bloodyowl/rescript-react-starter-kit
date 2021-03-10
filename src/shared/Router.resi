type url = RescriptReactRouter.url

let publicPath: string

let makeHref: string => string

let useUrl: (~serverUrl: url=?, unit) => url

let push: string => unit

let replace: string => unit

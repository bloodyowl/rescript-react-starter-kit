@val external publicPath: option<string> = "process.env.PUBLIC_PATH"

let publicPath = publicPath->Option.getWithDefault("/")

let join = (s1, s2) =>
  `${s1}/${s2}`
  ->Js.String2.replaceByRe(%re("/:\/\//g"), "__PROTOCOL__")
  ->Js.String2.replaceByRe(%re("/\/+/g"), "/")
  ->Js.String2.replaceByRe(%re("/__PROTOCOL__/g"), "://")

let makeHref = join(publicPath)

let rec stripInitialPath = (path, sourcePath) => {
  switch (path, sourcePath) {
  | (list{a1, ...a2}, list{b1, ...b2}) if a1 === b1 => stripInitialPath(a2, b2)
  | (path, _) => path
  }
}

// copied from RescriptReactRouter
let pathParse = str =>
  switch str {
  | "" | "/" => list{}
  | raw =>
    /* remove the preceeding /, which every pathname seems to have */
    let raw = Js.String.sliceToEnd(~from=1, raw)
    /* remove the trailing /, which some pathnames might have. Ugh */
    let raw = switch Js.String.get(raw, Js.String.length(raw) - 1) {
    | "/" => Js.String.slice(~from=0, ~to_=-1, raw)
    | _ => raw
    }
    /* remove search portion if present in string */
    let raw = switch raw |> Js.String.splitAtMost("?", ~limit=2) {
    | [path, _] => path
    | _ => raw
    }

    raw
    |> Js.String.split("/")
    |> Js.Array.filter(item => String.length(item) != 0)
    |> List.fromArray
  }

type url = RescriptReactRouter.url

let useUrl = (~serverUrl=?, ()) => {
  let url = RescriptReactRouter.useUrl(~serverUrl?, ())

  React.useMemo1(() => {
    {...url, path: stripInitialPath(url.path, pathParse(publicPath))}
  }, [url])
}

let push = url => {
  RescriptReactRouter.push(makeHref(url))
}

let replace = url => {
  RescriptReactRouter.replace(makeHref(url))
}

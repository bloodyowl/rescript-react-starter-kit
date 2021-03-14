# ReScript React Starter Kit

> An opinionated starter kit for ReScript React

<img width="626" alt="Screen Shot 2021-02-27 at 23 45 09" src="https://user-images.githubusercontent.com/1688645/109402443-321f6a00-7956-11eb-8883-1e2e6d3ec3ad.png">

## What's inside

### Familiar standard library

The configuration automatically gives you [Belt](https://rescript-lang.org/docs/manual/latest/api/belt) and [ReScriptJs.Js](https://github.com/bloodyowl/rescript-js) in scope.

This makes your code always default to JavaScript APIs if available, while giving you good manipulation functions for ReScript-specific types (like `Option` & `Result`)

This means that by default, the following code:

```rescript
let x = [1, 2, 3]
  ->Array.map(x => x * 2)
  ->Array.forEach(Console.log)
```

will compile to the following JS (no additional runtime cost!):

```js
[1, 2, 3]
  .map(function (x) {
    return x << 1;
  })
  .forEach(function (prim) {
    console.log(prim);
  });
```

If you need a specific data-structure from Belt, you can prefix with `Belt`'s scope:

```rescript
let x = Belt.Map.String.fromArray([("a", 1), ("b", 2)])
```

### Ready-to-go requests

This starter kit gives you three building blocks to handle API calls from the get go.

#### AsyncData

[AsyncData](https://github.com/bloodyowl/rescript-asyncdata) is a great way to represent asynchronous data in React component state. It's a variant type that can be either `NotAsked`, `Loading` or `Done(payload)`, leaving no room for the errors you get when managing those in different state cells.

#### Future

Promises don't play really well with React's effect cancellation model, [Future](https://github.com/bloodyowl/rescript-future) gives you a performant equivalent that has built-in cancellation and leaves error management to the [Result](https://rescript-lang.org/docs/manual/latest/api/belt/result) type.

#### Request

[Request](https://github.com/bloodyowl/rescript-request) gives you a simple API to perform API calls in a way that's easy to store in React component state.

### Dev server

Once your project grows, having the compiler output files and webpack watching it can lead to long waiting times. Here, the development server waits for BuckleScript to be ready before it triggers a compilation.

The dev server supports basic **live reload**.

### Testing library

With [ReScriptTest](https://github.com/bloodyowl/rescript-test), you get a light testing framework that plays nicely with React & lets you mock HTTP call responses.

The assertion part is on your side, the library simply runs and renders the tests.

```rescript
open ReactTest

testWithReact("Robots renders", container => {
  let (future, resolve) = Deferred.make()

  let fetchRobotsTxt = () => future

  act(() => ReactDOM.render(<Robots fetchRobotsTxt />, container))
  Assert.elementContains(container, "Loading")

  act(() => resolve(Ok({ok: true, status: 200, response: Some("My mock response")})))

  Assert.elementContains(container, "My mock response")
})
```

Check the example output in [this repo's GitHub Actions](https://github.com/bloodyowl/rescript-react-starter-kit/actions)

### Styling with Emotion

With [some zero-cost bindings to Emotion](https://github.com/bloodyowl/rescript-react-starter-kit/blob/main/src/shared/Emotion.res), you get CSS-in-ReScript right away.

```rescript
module Styles = {
  open Emotion
  let actionButton = css({
    "borderStyle": "none",
    "background": "hotpink",
    "fontFamily": "inherit",
    "color": "#fff",
    "fontSize": 20,
    "padding": 10,
    "cursor": "pointer",
    "borderRadius": 10,
    "alignSelf": "center",
  })
  let disabledButton = cx([actionButton, css({"opacity": "0.3"})])
}
```

## Routing

Provide a `PUBLIC_PATH` environment variable (defaults to `/`), the boilerplate takes care of the rest. Manage your routing using the `Router` & `<Link />` modules.

## Titles & metadata

Call `<Head />` with the metadata you like for a given route, this binds to [react-helmet](https://github.com/nfl/react-helmet).

## Getting started

```console
$ yarn
$ yarn start
# And in a second terminal tab
$ yarn server
```

## Commands

### yarn start

Starts ReScript compiler in watch mode

### yarn server

Starts the development server

### yarn build

Builds the project

### yarn bundle

Bundles the project in `build`

### yarn test

Runs the test suite

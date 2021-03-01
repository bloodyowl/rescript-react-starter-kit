open Test

@send external remove: Dom.element => unit = "remove"

let createContainer = () => {
  let containerElement: Dom.element = document["createElement"]("div")
  let _ = document["body"]["appendChild"](containerElement)
  containerElement
}

let cleanupContainer = container => {
  ReactDOM.unmountComponentAtNode(container)
  remove(container)
}

let testWithReact = testWith(~setup=createContainer, ~teardown=cleanupContainer)

let testAsyncWithReact = testAsyncWith(~setup=createContainer, ~teardown=cleanupContainer)

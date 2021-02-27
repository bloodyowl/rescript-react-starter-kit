module Styles = {
  open CssJs
  let container = style(. [fontFamily(#sansSerif)])
  let actionButton = style(. [
    borderStyle(none),
    background(hotpink),
    fontFamily(inherit_),
    color("fff"->hex),
    fontSize(20->px),
    padding(10->px),
    cursor(pointer),
  ])
}

module App = {
  @react.component
  let make = () => {
    let (robots, setRobots) = React.useState(() => AsyncData.NotAsked)

    <div className=Styles.container>
      <h1> {"Hello world!"->React.string} </h1>
      <button
        className=Styles.actionButton
        disabled={robots->AsyncData.isLoading}
        onClick={_ => {
          setRobots(_ => Loading)
          Request.make(~url="/robots.txt", ~responseType=Text, ())->Future.get(payload =>
            setRobots(_ => Done(payload))
          )
        }}>
        {"Load robots.txt"->React.string}
      </button>
      {switch robots {
      | NotAsked => React.null
      | Loading => "Loading …"->React.string
      | Done(Ok({ok: true, response: Some(robots)})) => <pre> {robots->React.string} </pre>
      | Done(_) => "An error occured"->React.string
      }}
    </div>
  }
}

switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<App />, root)
| None => Console.error("Missing #root element")
}

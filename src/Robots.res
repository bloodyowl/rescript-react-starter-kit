module Styles = {
  open CssJs
  let container = style(. [
    fontFamily(#sansSerif),
    flexGrow(1.0),
    display(flexBox),
    flexDirection(column),
    alignItems(stretch),
    justifyContent(center),
    width(100.0->pct),
    maxWidth(600->px),
    margin(auto),
  ])
  let actionButton = style(. [
    borderStyle(none),
    background(hotpink),
    fontFamily(inherit_),
    color("fff"->hex),
    fontSize(20->px),
    padding(10->px),
    cursor(pointer),
    borderRadius(10->px),
    alignSelf(center),
  ])
  let disabledButton = merge(. [actionButton, style(. [opacity(0.3)])])
  let results = style(. [
    height(200->px),
    backgroundColor("efefef"->hex),
    borderRadius(10->px),
    width(100.0->pct),
    padding(10->px),
  ])
}

let fetchRobotsTxt = () =>
  Request.make(~url=`${Router.publicPath}robots.txt`, ~responseType=Text, ())
  // We can make the loading state more obvious by making the request a bit longer
  ->Future.flatMap(~propagateCancel=true, value => {
    Future.make(resolve => {
      let timeoutId = setTimeout(() => {
        resolve(value)
      }, 1_000)
      Some(() => clearTimeout(timeoutId))
    })
  })

@react.component
let make = (~fetchRobotsTxt=fetchRobotsTxt) => {
  let (robots, setRobots) = React.useState(() => AsyncData.NotAsked)

  React.useEffect1(() => {
    setRobots(_ => Loading)
    let request = fetchRobotsTxt()
    request->Future.get(payload => {
      setRobots(_ => Done(payload))
    })
    // Cancellation is built-in, in our case with the artificial slow down
    // It'll cancel both the request and the timer, because we've set the
    // `propagateCancel` option to true
    Some(() => request->Future.cancel)
  }, [fetchRobotsTxt])

  <>
    <Head> <title> {"Request demo"->React.string} </title> </Head>
    <div className=Styles.container>
      <button
        className={robots->AsyncData.isLoading ? Styles.disabledButton : Styles.actionButton}
        disabled={robots->AsyncData.isLoading}
        onClick={_ => {
          setRobots(_ => Loading)
          fetchRobotsTxt()->Future.get(payload => setRobots(_ => Done(payload)))
        }}>
        {switch robots {
        | NotAsked => "Load robots.txt"->React.string
        | Loading => `Loading …`->React.string
        | Done(_) => "Reload robots.txt"->React.string
        }}
      </button>
      <Spacer height="10px" />
      <div className=Styles.results>
        {switch robots {
        | NotAsked | Loading => React.null
        | Done(Ok({ok: true, response: Some(robots)})) => <pre> {robots->React.string} </pre>
        | Done(_) => "An error occured"->React.string
        }}
      </div>
    </div>
  </>
}

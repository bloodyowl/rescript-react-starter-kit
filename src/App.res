include CssReset

module App = {
  @react.component
  let make = () => {
    let url = Router.useUrl()

    React.useEffect1(() => {
      let () = window["scrollTo"](0, 0)
      None
    }, [url.path])

    <>
      <Header />
      {switch url.path {
      | list{} => <Home />
      | list{"robots"} => <Robots />
      | _ => <ErrorPage text="Not found" />
      }}
      <Footer />
    </>
  }
}

switch ReactDOM.querySelector("#root") {
| Some(root) => ReactDOM.render(<App />, root)
| None => Console.error("Missing #root element")
}

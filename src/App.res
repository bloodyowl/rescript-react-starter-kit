Emotion.injectGlobal(`
html {
  padding: 0;
  margin: 0;
  height: -webkit-fill-available;
  font-family: sans-serif;
}
body {
  padding: 0; 
  margin: 0;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  min-height: -webkit-fill-available;
}
#root {
  display: flex;
  flex-direction: column;
  flex-grow: 1
}`)

module App = {
  @react.component
  let make = () => {
    let url = Router.useUrl()

    React.useEffect1(() => {
      let () = window["scrollTo"](. 0, 0)
      None
    }, [url.path])

    <>
      <Head
        defaultTitle="ReScript React Starter Kit" titleTemplate="%s - ReScript React Starter Kit"
      />
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

open ReactTest

testWithReact("Robots renders", container => {
  let (future, resolve) = Deferred.make()

  let fetchRobotsTxt = () => future

  act(() => ReactDOM.render(<Robots fetchRobotsTxt />, container))
  Assert.elementContains(~message="Renders loading", container, "Loading")

  act(() =>
    resolve(
      Ok({
        ok: true,
        status: 200,
        response: Some("My mock response"),
        xhr: Request.asXhr(Object.empty()),
      }),
    )
  )

  Assert.elementContains(~message="Renders received payload", container, "My mock response")
})

open ReactTest
open ReactTestUtils

testWithReact("Robots renders", container => {
  let (future, resolve) = Deferred.make()

  let fetchRobotsTxt = () => future

  act(() => ReactDOM.render(<Robots fetchRobotsTxt />, container))
  Assert.elementContains(container, "Loading")

  act(() => resolve(Ok({ok: true, status: 200, response: Some("My mock response")})))

  Assert.elementContains(container, "My mock response")
})

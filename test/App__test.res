open ReactTest
open ReactTestUtils

testWithReact("App renders", container => {
  act(() => ReactDOM.render(<App.App />, container))

  Assert.elementContains(container, "Hello world")
})

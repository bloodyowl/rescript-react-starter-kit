open ReactTest
open ReactTestUtils

testWithReact("Home renders", container => {
  act(() => ReactDOM.render(<Home />, container))

  Assert.elementContains(container, "Welcome")
})

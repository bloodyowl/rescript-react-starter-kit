open ReactTest
open ReactTestUtils

testWithReact("App renders", container => {
  act(() => ReactDOM.render(<Robots />, container))

  Assert.elementContains(container, "Hello world")
})

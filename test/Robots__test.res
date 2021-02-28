open Test
open ReactTest
open ReactTestUtils

testAsyncWithReact("Robots renders", (container, done) => {
  let (future, resolve) = Deferred.make()
  http((req, res) => {
    switch req["url"] {
    | "http://localhost:3000/robots.txt" =>
      res["status"](200)["set"]("Content-Type", "text/plain")["end"]("My mock response")
      let _ = setTimeout(() => resolve(), 16)
    | _ => res["status"](404)["end"]("")
    }
  })

  act(() => ReactDOM.render(<Robots />, container))
  Assert.elementContains(container, "Loading")

  future->Future.get(() => {
    act(() => ReactDOM.render(<Robots />, container))
    Assert.elementContains(container, "My mock response")
    done()
  })
})

open Test

@get external textContent: Dom.element => string = "textContent"

let elementContains = (~message=?, element: Dom.element, substring: string) =>
  assertion(
    ~message?,
    ~operator="elementContains",
    (textContent, substring) => {
      textContent->String.includes(substring)
    },
    element->textContent,
    substring,
  )

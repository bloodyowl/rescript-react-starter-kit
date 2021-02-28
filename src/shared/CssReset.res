open CssJs

global(.
  "html",
  [padding(zero), margin(zero), unsafe("height", "-webkit-fill-available"), fontFamily(#sansSerif)],
)

global(. "body", [minHeight(100.0->vh)])
global(.
  "body",
  [
    padding(zero),
    margin(zero),
    display(flexBox),
    flexDirection(column),
    unsafe("minHeight", "-webkit-fill-available"),
  ],
)

global(. "#root", [display(flexBox), flexDirection(column), flexGrow(1.0)])

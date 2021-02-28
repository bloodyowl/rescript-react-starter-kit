module Styles = {
  open CssJs
  let container = style(. [width(100.0->pct), maxWidth(800->px), margin(auto)])
  let text = style(. [textAlign(center), fontSize(32->px)])
}

@react.component
let make = () => {
  <div className=Styles.container>
    <p className=Styles.text> {"Welcome to ReScript React Starter Kit!"->React.string} </p>
  </div>
}

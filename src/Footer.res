module Styles = {
  open CssJs
  let container = style(. [flexGrow(0.0), padding(10->px)])
  let copyright = style(. [textAlign(center), margin(zero), fontSize(14->px)])
}

@react.component
let make = () => {
  <footer className=Styles.container>
    <div className=Styles.copyright> {`© bloodyowl 2021`->React.string} </div>
  </footer>
}

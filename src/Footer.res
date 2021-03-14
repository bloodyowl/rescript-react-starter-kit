module Styles = {
  open Emotion
  let container = css({
    "flexGrow": 0,
    "padding": 10,
  })
  let copyright = css({
    "textAlign": "center",
    "margin": 0,
    "fontSize": 14,
  })
}

@react.component
let make = () => {
  <footer className=Styles.container>
    <div className=Styles.copyright> {`© bloodyowl 2021`->React.string} </div>
  </footer>
}

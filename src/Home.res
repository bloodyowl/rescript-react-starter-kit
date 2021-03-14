module Styles = {
  open Emotion
  let container = css({
    "width": "100%",
    "maxWidth": 800,
    "margin": "auto",
  })
  let text = css({
    "textAlign": "center",
    "fontSize": 32,
  })
}

@react.component
let make = () => {
  <>
    <Head> <title> {"Welcome"->React.string} </title> </Head>
    <div className=Styles.container>
      <p className=Styles.text> {"Welcome to ReScript React Starter Kit!"->React.string} </p>
    </div>
  </>
}

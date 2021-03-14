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
    "color": "rgba(0, 0, 0, 0.5)",
  })
}

@react.component
let make = (~text) => {
  <>
    <Head> <title> {text->React.string} </title> </Head>
    <div className=Styles.container>
      <div className=Styles.text> {`❌`->React.string} </div>
      <Spacer height="5px" />
      <div className=Styles.text> {text->React.string} </div>
    </div>
  </>
}

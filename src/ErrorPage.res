module Styles = {
  open CssJs
  let container = style(. [width(100.0->pct), maxWidth(800->px), margin(auto)])
  let text = style(. [textAlign(center), fontSize(32->px), color(rgba(0, 0, 0, #num(0.5)))])
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

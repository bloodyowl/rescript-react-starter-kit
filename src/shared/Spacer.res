@react.component
let make = (~width="10px", ~height="10px", ()) => {
  <div style={ReactDOM.Style.make(~flexShrink="0", ~flexGrow="0", ~width, ~height, ())} />
}

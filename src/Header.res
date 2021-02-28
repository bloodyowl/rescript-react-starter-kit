module Styles = {
  open CssJs
  let container = style(. [flexGrow(0.0), padding(10->px)])
  let title = style(. [textAlign(center), margin(zero), fontSize(24->px)])
  let nav = style(. [
    display(flexBox),
    flexDirection(row),
    alignItems(stretch),
    justifyContent(center),
    padding(10->px),
  ])
  let navItem = style(. [
    padding(10->px),
    textDecoration(none),
    color("0091FF"->hex),
    borderRadius(5->px),
  ])
  let activeNavItem = style(. [backgroundColor("0091FF"->hex), color("fff"->hex)])
}

@react.component
let make = () => {
  <header className=Styles.container>
    <h1 className=Styles.title> {"ReScript React Starter Kit"->React.string} </h1>
    <nav className=Styles.nav>
      <Link href="/" className=Styles.navItem activeClassName=Styles.activeNavItem>
        {"Home"->React.string}
      </Link>
      <Link href="/robots" className=Styles.navItem activeClassName=Styles.activeNavItem>
        {"Request demo"->React.string}
      </Link>
    </nav>
  </header>
}

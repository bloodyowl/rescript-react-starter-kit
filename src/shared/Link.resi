@react.component
let make: (
  ~href: string,
  ~matchHref: string=?,
  ~className: string=?,
  ~style: ReactDOM.Style.t=?,
  ~activeClassName: string=?,
  ~activeStyle: ReactDOM.Style.t=?,
  ~matchSubroutes: bool=?,
  ~title: string=?,
  ~children: React.element,
) => React.element

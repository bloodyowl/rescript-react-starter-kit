@react.component @module("react-helmet")
external make: (
  ~defaultTitle: string=?,
  ~titleTemplate: string=?,
  ~children: React.element=?,
) => React.element = "Helmet"

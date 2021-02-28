// The fetchRobotsTxt enables us to pass a mock function for testing
@react.component
let make: (
  ~fetchRobotsTxt: unit => Future.t<result<Request.response<string>, Request.error>>=?,
) => React.element

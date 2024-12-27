import web
import gleam/string_tree
import gleam/int
import wisp.{File, type Request, type Response}
import glotel/span
import glotel/span_kind

pub fn handle_request(req: Request, priv_static: String) -> Response {
  use _req <- web.middleware(req, priv_static)

  case wisp.path_segments(req) {
    [] -> wisp.response(200) |> wisp.set_body(File(path: priv_static <> "/index.html"))
    ["rolldice"] -> roll_dice(req)
    _ -> wisp.not_found()
  }
}

fn roll_dice(req: Request) -> Response {
  span.extract_values(req.headers)

  use span_ctx <- span.new_of_kind(span_kind.Server, "GET /rolldice", [
    #("http.method", "GET"),
    #("http.route", "/rolldice"),
    ])

  let roll = int.random(5) + 1

  span.set_attribute(
    span_ctx,
    "roll.value",
    int.to_string(roll),
  )

  let body = string_tree.from_string(int.to_string(roll))
  wisp.html_response(body, 200)
}

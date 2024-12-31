import web
import gleam/int
import wisp.{type Request, type Response}
import glotel/span
import glotel/span_kind
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn handle_request(req: Request, priv_static: String) -> Response {
  use _req <- web.middleware(req, priv_static)

  case wisp.path_segments(req) {
    [] ->
      index("")
      |> element.to_document_string_builder
      |> wisp.html_response(200)
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

  // let body = string_tree.from_string(int.to_string(roll))
  wisp.response(200)
  |> wisp.string_body(int.to_string(roll))
  |> wisp.set_header("content-type", "text/plain")
}


pub fn index(trace_context) -> Element(t) {
  html.html([], [
    html.head([], [
      html.title([], "Roll Dice in Gleam"),
      html.meta([attribute.name("traceparent"), attribute.content(trace_context)]),
      html.meta([
        attribute.name("viewport"),
        attribute.attribute("content", "width=device-width, initial-scale=1"),
        ]),
      html.script([attribute.attribute("type", "module"),
        attribute.src("/static/instrument.js")], ""),
      html.script([attribute.attribute("type", "module"),
        attribute.src("/static/roll_dice_gleam.min.mjs")], ""),
    ]),
    html.body([], [html.div([attribute.id("app")], [])]),
  ])
}

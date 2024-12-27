import gleam/int
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element/html
import lustre/element.{type Element}
import lustre/event
import lustre/ui
import lustre_http as http

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", 0)

  Nil
}

type Model =
  Int

fn init(initial_count: Int) -> #(Model, Effect(Msg)) {
  case initial_count < 0 {
    True -> #(0, effect.none())
    False -> #(initial_count, effect.none())
  }
}

type Msg {
  Roll
  DiceRollResult(Result(String, http.HttpError))
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    Roll -> #(model, roll_dice())
    DiceRollResult(Ok(text_value)) ->
      case int.parse(text_value) {
        Ok(value) -> #(value, effect.none())
        Error(_) -> #(model, effect.none())
      }
    DiceRollResult(Error(_)) -> #(model, effect.none())
  }
}

fn roll_dice() -> Effect(Msg) {
  let url = "http://localhost:8000/rolldice"

  http.get(url, http.expect_text(DiceRollResult))
}


fn view(model: Model) -> Element(Msg) {
  let roll = int.to_string(model)

  ui.centre(
    [],
    ui.stack([], [
      html.p([], [
        element.text(roll),
        ]),
      ui.button([event.on_click(Roll)], [element.text("Roll")]),
    ]),
  )
}

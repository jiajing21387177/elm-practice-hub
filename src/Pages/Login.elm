module Pages.Login exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)

type alias Model = {}

type Msg = NoOp

init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )

view : Model -> Html Msg
view _ =
    h1 [ class "text-2xl" ] [ text "Login Page" ]
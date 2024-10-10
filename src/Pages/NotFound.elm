module Pages.NotFound exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

view : Html msg
view =
    h1 [ class "text-2xl text-red-500" ] [ text "404 - Page Not Found" ]
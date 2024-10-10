module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser exposing (..)

type Route
    = Home
    | Login
    | Products
    | Product Int

fromUrl : Url -> Maybe Route
fromUrl url =
    parse routeParser url

routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Home top
        , map Login (s "login")
        , map Products (s "products")
        , map Product (s "products" </> int)
        ]
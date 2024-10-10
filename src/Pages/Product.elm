module Pages.Product exposing (Model, Msg(..), Product, init, productDecoder, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, field)
import Json.Decode.Extra as Decode


type alias Model =
    { id : Int
    , product : Maybe Product
    , error : Maybe String
    }


type alias Product =
    { id : Int
    , productCategory : String
    , name : String
    , brand : String
    , description : String
    , basePrice : Float
    , inStock : Bool
    , stock : Int
    , featuredImage : String
    , thumbnailImage : String
    , storageOptions : List String
    , colorOptions : List String
    , display : String
    , cpu : String
    , camera : Maybe Camera
    , gpu : Maybe String
    }


type alias Camera =
    { rearCamera : String
    , frontCamera : String
    }


type Msg
    = FetchProduct
    | GetProduct (Result Http.Error Product)


init : Int -> ( Model, Cmd Msg )
init id =
    ( { id = id
      , product = Nothing
      , error = Nothing
      }
    , fetchProduct id
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchProduct ->
            ( model, fetchProduct model.id )

        GetProduct result ->
            case result of
                Ok product ->
                    ( { model | product = Just product, error = Nothing }, Cmd.none )

                Err _ ->
                    ( { model | error = Just "Failed to fetch product" }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ h1 [ class "text-2xl" ] [ text ("Product Details for ID: " ++ String.fromInt model.id) ]
        , viewProductOrError model
        ]


viewProductOrError : Model -> Html Msg
viewProductOrError model =
    case model.error of
        Just error ->
            div [ class "text-red-500" ] [ text error ]

        Nothing ->
            case model.product of
                Nothing ->
                    div [ class "text-gray-500" ] [ text "Loading product..." ]

                Just product ->
                    viewProduct product


viewProduct : Product -> Html Msg
viewProduct product =
    div []
        [ img
            [ height 100
            , src product.thumbnailImage
            ]
            []
        , h1 [] [ text product.name ]
        ]


fetchProduct : Int -> Cmd Msg
fetchProduct id =
    Http.get
        { url = "https://dummyapi.online/api/products/" ++ String.fromInt id
        , expect = Http.expectJson GetProduct productDecoder
        }


productDecoder : Decoder Product
productDecoder =
    Decode.succeed Product
        |> Decode.andMap (field "id" Decode.int)
        |> Decode.andMap (field "productCategory" Decode.string)
        |> Decode.andMap (field "name" Decode.string)
        |> Decode.andMap (field "brand" Decode.string)
        |> Decode.andMap (field "description" Decode.string)
        |> Decode.andMap (field "basePrice" Decode.float)
        |> Decode.andMap (field "inStock" Decode.bool)
        |> Decode.andMap (field "stock" Decode.int)
        |> Decode.andMap (field "featuredImage" Decode.string)
        |> Decode.andMap (field "thumbnailImage" Decode.string)
        |> Decode.andMap (field "storageOptions" (Decode.list Decode.string))
        |> Decode.andMap (field "colorOptions" (Decode.list Decode.string))
        |> Decode.andMap (field "display" Decode.string)
        |> Decode.andMap (field "CPU" Decode.string)
        |> Decode.andMap (Decode.maybe (field "camera" cameraDecoder))
        |> Decode.andMap (Decode.maybe (field "GPU" Decode.string))


cameraDecoder : Decoder Camera
cameraDecoder =
    Decode.map2 Camera
        (field "rearCamera" Decode.string)
        (field "frontCamera" Decode.string)

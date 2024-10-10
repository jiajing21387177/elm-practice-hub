-- File: src/Page/Products.elm


module Pages.Products exposing (Model, Msg(..), init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as Decode
import Pages.Product as Product


type alias Model =
    { products : List Product.Product
    , error : Maybe String
    }




type Msg
    = FetchProducts
    | GotProducts (Result Http.Error (List Product.Product))


init : ( Model, Cmd Msg )
init =
    ( { products = [], error = Nothing }
    , fetchProducts
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchProducts ->
            ( model, fetchProducts )

        GotProducts result ->
            case result of
                Ok products ->
                    ( { model | products = products, error = Nothing }, Cmd.none )

                Err _ ->
                    ( { model | error = Just "Failed to fetch products" }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ h1 [ class "text-2xl mb-4" ] [ text "Products" ]
        , viewProductsOrError model
        ]


viewProductsOrError : Model -> Html Msg
viewProductsOrError model =
    case model.error of
        Just error ->
            div [ class "text-red-500" ] [ text error ]

        Nothing ->
            if List.isEmpty model.products then
                div [ class "text-gray-500" ] [ text "Loading products..." ]

            else
                viewProducts model.products


viewProducts : List Product.Product -> Html Msg
viewProducts products =
    ul [ class "space-y-4" ]
        (List.map viewProduct products)


viewProduct : Product.Product -> Html Msg
viewProduct product =
    li [ class "border p-4 rounded shadow" ]
        [ h2 [ class "text-xl font-bold" ] [ text product.name ]
        , p [ class "text-gray-600" ] [ text product.description ]
        , p [ class "text-green-600 font-bold mt-2" ]
            [ text ("Price: $" ++ String.fromFloat product.basePrice) ]
        , a [ href ("/products/" ++ String.fromInt product.id), class "text-blue-500 hover:underline" ]
            [ text "View Details" ]
        ]


fetchProducts : Cmd Msg
fetchProducts =
    Http.get
        { url = "https://dummyapi.online/api/products"
        , expect = Http.expectJson GotProducts productsDecoder
        }

productsDecoder : Decoder (List Product.Product)
productsDecoder =
    Decode.list Product.productDecoder
module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Route as Route
import Pages.Home as Home
import Pages.Login as Login
import Pages.Products as Products
import Pages.Product as Product
import Pages.NotFound as NotFound

main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }

type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , page : Page
    }

type Page
    = HomePage Home.Model
    | LoginPage Login.Model
    | ProductsPage Products.Model
    | ProductPage Product.Model
    | NotFoundPage

type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | LoginMsg Login.Msg
    | ProductsMsg Products.Msg
    | ProductMsg Product.Msg

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    updateUrl url { key = key, url = url, page = NotFoundPage }

updateUrl : Url.Url -> Model -> ( Model, Cmd Msg )
updateUrl url model =
    case Route.fromUrl url of
        Just Route.Home ->
            Home.init
                |> updateWith HomePage HomeMsg model

        Just Route.Login ->
            Login.init
                |> updateWith LoginPage LoginMsg model

        Just Route.Products ->
            Products.init
                |> updateWith ProductsPage ProductsMsg model

        Just (Route.Product id) ->
            Product.init id
                |> updateWith ProductPage ProductMsg model

        Nothing ->
            ( { model | page = NotFoundPage }, Cmd.none )

updateWith : (subModel -> Page) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toPage toMsg model ( subModel, subCmd ) =
    ( { model | page = toPage subModel }
    , Cmd.map toMsg subCmd
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            updateUrl url model

        ( HomeMsg subMsg, HomePage subModel ) ->
            Home.update subMsg subModel
                |> updateWith HomePage HomeMsg model

        ( LoginMsg subMsg, LoginPage subModel ) ->
            Login.update subMsg subModel
                |> updateWith LoginPage LoginMsg model

        ( ProductsMsg subMsg, ProductsPage subModel ) ->
            Products.update subMsg subModel
                |> updateWith ProductsPage ProductsMsg model

        ( ProductMsg subMsg, ProductPage subModel ) ->
            Product.update subMsg subModel
                |> updateWith ProductPage ProductMsg model

        _ ->
            ( model, Cmd.none )

view : Model -> Browser.Document Msg
view model =
    { title = "skudata"
    , body =
        [ div [ class "container mx-auto p-4" ]
            [ viewNav
            , case model.page of
                HomePage subModel ->
                    Home.view subModel
                        |> Html.map HomeMsg

                LoginPage subModel ->
                    Login.view subModel
                        |> Html.map LoginMsg

                ProductsPage subModel ->
                    Products.view subModel
                        |> Html.map ProductsMsg

                ProductPage subModel ->
                    Product.view subModel
                        |> Html.map ProductMsg

                NotFoundPage ->
                    NotFound.view
            ]
        ]
    }

viewNav : Html msg
viewNav =
    nav [ class "mb-4" ]
        [ a [ href "/", class "mr-2" ] [ text "Home" ]
        , a [ href "/login", class "mr-2" ] [ text "Login" ]
        , a [ href "/products", class "mr-2" ] [ text "Products" ]
        ]
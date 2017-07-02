module Main exposing (main)

import Html exposing (Html, div, pre, text)
import Html.Attributes exposing (style)
import Http
import Json.Decode as Decode exposing (value)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { analysis : Maybe Analysis
    , error : Maybe Http.Error
    }


type alias Analysis =
    Decode.Value


type Msg
    = NoOp
    | DataFetched (Result Http.Error Analysis)


init : ( Model, Cmd Msg )
init =
    { analysis = Nothing
    , error = Nothing
    }
        ! [ fetchData "paper-icon-button" ]


fetchData component =
    let
        url =
            "https://www.webcomponents.org/api/docs/PolymerElements/"
                ++ component
                ++ "?use_analyzer_data"

        _ =
            Debug.log "Getting analysis" url
    in
        Http.get url Decode.value
            |> Http.send DataFetched


update : Msg -> Model -> ( Model, Cmd Msg )
update msg state =
    case msg of
        NoOp ->
            state ! []

        DataFetched (Ok value) ->
            let
                _ =
                    Debug.log "Data fetch OK" value
            in
                { state | analysis = Just value } ! []

        DataFetched (Err message) ->
            let
                _ =
                    Debug.log "Error fetching data" message
            in
                { state | error = Just message } ! []


subscriptions : Model -> Sub Msg
subscriptions state =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ errorBox model.error
        , codeBox model.analysis
        ]


codeBox analysis =
    case analysis of
        Nothing ->
            pre [] [ text "Loading analyzer data..." ]

        Just data ->
            div [] [ text (toString data) ]


errorBox error =
    case error of
        Nothing ->
            div [] []

        Just error ->
            pre
                [ style
                    [ ( "background", "red" )
                    ]
                ]
                [ text (toString error) ]

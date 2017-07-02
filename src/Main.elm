module Main exposing (main)

import Types exposing (..)
import View exposing (view)
import Http
import Json.Decode as Decode exposing (value)
import Html


main : Program Never Model Action
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : ( Model, Cmd Action )
init =
    { component = Nothing
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
            Debug.log "Fetching analysis" url
    in
        Http.get url Decode.value
            |> Http.send DataFetched


update : Action -> Model -> ( Model, Cmd Action )
update action state =
    case action of
        NoOp ->
            state ! []

        DataFetched (Ok json) ->
            let
                _ =
                    Debug.log "Data fetch OK"
            in
                { state | component = Just json } ! []

        DataFetched (Err message) ->
            let
                _ =
                    Debug.log "Error fetching data" message
            in
                { state | error = Just message } ! []


subscriptions : Model -> Sub Action
subscriptions state =
    Sub.none

module Main exposing (main)

import Html
import Http
import Json.Decode as Decode exposing (value)
import Types exposing (..)
import View exposing (view)


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
        ! [ fetchData "app-layout" ]


fetchData : String -> Cmd Action
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


decodeComponent : Decode.Value -> Component
decodeComponent json =
    { elements = decodeElements json }


decodeElements : Decode.Value -> List Element
decodeElements json =
    let
        elementsDecoder =
            Decode.at [ "analysis", "elements" ] (Decode.list Decode.value)
    in
        case Decode.decodeValue elementsDecoder json of
            Ok values ->
                List.map decodeElement values

            Err message ->
                Debug.crash message


decodeElement : Decode.Value -> Element
decodeElement json =
    case Decode.decodeValue (Decode.at [ "tagname" ] (Decode.string)) json of
        Ok tagname ->
            Element tagname

        Err message ->
            Debug.crash message


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
                { state | component = Just (decodeComponent json) } ! []

        DataFetched (Err message) ->
            let
                _ =
                    Debug.log "Error fetching data" message
            in
                { state | error = Just message } ! []


subscriptions : Model -> Sub Action
subscriptions state =
    Sub.none

module Main exposing (main)

import Html
import Http
import Json.Decode as Decode exposing (value)
import Set
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
    { elements = decodeElements json
    , attributes = decodeAttributes json
    }


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
    let
        elementDecoder =
            Decode.at [ "tagname" ] Decode.string
    in
        case Decode.decodeValue elementDecoder json of
            Ok tagname ->
                Element tagname

            Err message ->
                Debug.crash message


decodeAttributes : Decode.Value -> List Attribute
decodeAttributes json =
    let
        -- DRY: elementsDecoder is the same here as in decodeElements
        --      it will be the same for decodeEvents as well
        elementsDecoder =
            Decode.at [ "analysis", "elements" ] (Decode.list Decode.value)
    in
        case Decode.decodeValue elementsDecoder json of
            Ok values ->
                List.map decodeAttributesFromElement values
                    |> List.concat

            {- TODO: How to make list unique?

               This doesn't work as Attribute is not comparable

               |> Set.fromList
               |> Set.toList
               -
            -}
            Err message ->
                Debug.crash message


decodeAttributesFromElement : Decode.Value -> List Attribute
decodeAttributesFromElement json =
    let
        attributesDecoder =
            Decode.at [ "attributes" ] (Decode.list Decode.value)
    in
        case Decode.decodeValue attributesDecoder json of
            Ok values ->
                List.map decodeAttribute values

            Err message ->
                Debug.crash message


decodeAttribute : Decode.Value -> Attribute
decodeAttribute json =
    let
        attributeDecoder =
            Decode.map2 Attribute
                (Decode.at [ "name" ] Decode.string)
                (Decode.at [ "type" ] (Decode.succeed String))
    in
        case Decode.decodeValue attributeDecoder json of
            Ok attribute ->
                attribute

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

module Main exposing (main)

import Html exposing (Html, pre, text)


main : Program Never Model Msg
main =
    Html.program
        { init = state ! []
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    ()


type Msg
    = NoOp


state : Model
state =
    ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg state =
    case msg of
        NoOp ->
            state ! []


subscriptions : Model -> Sub Msg
subscriptions state =
    Sub.none


view : Model -> Html Msg
view model =
    pre [] [ text "Let's get started!" ]

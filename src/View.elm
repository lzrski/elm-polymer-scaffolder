module View exposing (view)

import Types exposing (..)
import Html exposing (Html, div, pre, text)
import Html.Attributes exposing (attribute, style)


view : Model -> Html Action
view model =
    div []
        [ errorBox model.error
        , codeBox model.component
        ]


codeBox component =
    case component of
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

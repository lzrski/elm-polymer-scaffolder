module Types exposing (..)

import Html exposing (Attribute)
import Http
import Json.Decode as Decode


-- MODEL AND ACTION (AKA MSG)


type alias Model =
    { component : Maybe Decode.Value -- Component
    , error : Maybe Http.Error
    }


type Action
    = NoOp
    | DataFetched (Result Http.Error Decode.Value)


{-| Component represents analyzer data for a single Web Component
-}
type alias Component =
    { elements : List Element
    , attributes : List Attribute
    , events : List Event
    }


type Element
    = Element String


type Attribute
    = Attribute String


type Event
    = Event String
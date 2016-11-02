import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App

main =
    Html.App.beginnerProgram
        { model = model
        , view = view
        , update = update
        }

-- MODEL
model =
  {
    leagues = [ { name = "Premier League", checked = False}
              , { name = "La Liga", checked = False}
    ]
  }

type alias Model =
    { 
      leagues : List League
    }

type alias League =
    { name : String
    , checked : Bool
    }


-- UPDATE
type Msg
    = ChangeNewCommentUser

update : Msg -> Model -> Model
update msg model =
    case msg of
      ChangeNewCommentUser -> model


-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ 
          checkboxList model
        ]

leagueView : League -> Html Msg
leagueView league =
    div[][
      label [] [ text league.name ]
      , input [ type' "checkbox" ] []
    ]
    

checkboxList : Model -> Html Msg
checkboxList model =
    div [ ]
        (List.map leagueView model.leagues)




-- checkbox: checked, unchecked
-- if checked, show fixtures for that date
-- 

--selectedDate

--league
--{
--  name: string
--  checked: boolean
--}

--leagues: []
--fixtures: []

--show fixtures in checked leagues for selectedDate
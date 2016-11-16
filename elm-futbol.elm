import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App

main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

-- MODEL
model =
  {
    leagues = [ { name = "Premier League", checked = False, id = 426}
              , { name = "La Liga", checked = False, id = 436}
              , { name = "Bundesliga", checked = False, id = 430}
              , { name = "Serie A", checked = False, id = 438}
    ]
  }

--  , { name = "Ligue 1", checked = False, id = 434}
--  , { name = "Champions League", checked = False, id = 440}

type alias Model =
    { 
      leagues : List League
    }

type alias League =
    { name : String
    , checked : Bool
    , id: Int
    }

init : (Model, Cmd Msg)
init =
  (Model [ { name = "Premier League", checked = False, id = 426}
              , { name = "La Liga", checked = False, id = 436}
              , { name = "Bundesliga", checked = False, id = 430}
              , { name = "Serie A", checked = False, id = 438}
    ], Cmd.none)

-- The exclamation point in model ! [] is just a short-hand function for (model, Cmd.batch []), 
-- which is the type returned from typical update statements

-- UPDATE
type Msg
    = Check Int Bool

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
      Check id isChecked ->
            let
                updateLeague t =
                    if t.id == id then
                        { t | checked = isChecked }
                    else
                        t
            in
                { model | leagues = List.map updateLeague model.leagues }
                    ! []


-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ 
          checkboxList model
        ]

toString : Bool -> String 
toString x = if x then "True" else "False"

--onClick (Check todo.id (not todo.completed))
leagueView : League -> Html Msg
leagueView league =
    div[][
      label [] [ text league.name, text (toString league.checked) ]
      , input [ type' "checkbox", onClick (Check league.id (not league.checked)) ] []
    ]
    

checkboxList : Model -> Html Msg
checkboxList model =
    fieldset [ ]
        (List.map leagueView model.leagues)

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none




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
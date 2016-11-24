import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

-- MODEL
--model =
--  {
--    leagues = [ { name = "Premier League", checked = False, id = 426}
--              , { name = "La Liga", checked = False, id = 436}
--              , { name = "Bundesliga", checked = False, id = 430}
--              , { name = "Serie A", checked = False, id = 438}
--    ]
--  }

--  , { name = "Ligue 1", checked = False, id = 434}
--  , { name = "Champions League", checked = False, id = 440}

type alias Model =
    { 
      leagues : List League
    , fixtures: List Fixture
    }

type alias League =
    { name : String
    , checked : Bool
    , id: Int
    }

type alias Fixture =
    { date : String
    , status : String
    , matchday : Int
    , homeTeamName : String
    , awayTeamName : String
    , result : FixtureResult
    , competition: Int
    }

type alias FixtureResultHalfTime =
    { goalsHomeTeam : Int
    , goalsAwayTeam : Int
    }

type alias FixtureResult =
    { goalsHomeTeam : Int
    , goalsAwayTeam : Int
    }


init : (Model, Cmd Msg)
init =
  ((Model [ { name = "Premier League", checked = True, id = 426}
              , { name = "La Liga", checked = True, id = 436}
              , { name = "Bundesliga", checked = True, id = 430}
              , { name = "Serie A", checked = True, id = 438}
    ] [ {  date = "2016-10-15T14:00:00Z" 
         , status = "FINISHED" 
         , matchday = 8 
         , homeTeamName = "Stoke City FC" 
         , awayTeamName = "Sunderland AFC"
         , result = { goalsHomeTeam = 2 , goalsAwayTeam = 0 }
         , competition = 426
        }
      , {  date = "2016-10-15T13:00:00Z" 
         , status = "FINISHED" 
         , matchday = 8 
         , homeTeamName = "SSC Napoli" 
         , awayTeamName = "AS Roma"
         , result = { goalsHomeTeam = 1 , goalsAwayTeam = 3 }
         , competition = 438
        }
      , {  date = "2016-10-15T14:15:00Z" 
         , status = "FINISHED" 
         , matchday = 8 
         , homeTeamName = "FC Barcelona" 
         , awayTeamName = "RC Deportivo La Coruna"
         , result = { goalsHomeTeam = 4 , goalsAwayTeam = 0 }
         , competition = 436
        }
      , {  date = "2016-10-14T18:30:00Z" 
         , status = "FINISHED" 
         , matchday = 7 
         , homeTeamName = "Borussia Dortmund" 
         , awayTeamName = "Hertha BSC"
         , result = { goalsHomeTeam = 1, goalsAwayTeam = 1 }
         , competition = 430
        }
        ]), Cmd.none)

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
    let
      checkedLeagues = List.map .id <| List.filter .checked model.leagues

      --_ = Debug.log "checkedLeagues" <| toString checkedLeagues
      visibleFixtures = List.filter (\x -> List.member x.competition checkedLeagues) model.fixtures
      _ = Debug.log "visibleFixtures" <| toString visibleFixtures
    in 
    div []
        [ 
          checkboxList model
          , fixtureList visibleFixtures
        ]

boolToString : Bool -> String 
boolToString x = if x then " True" else " False"

--onClick (Check todo.id (not todo.completed))
leagueView : League -> Html Msg
leagueView league =
    div[][
      label [] [ text league.name, text (boolToString league.checked) ]
    , input [ type_ "checkbox", checked league.checked, onClick (Check league.id (not league.checked)) ] []
    ]

fixtureList : List Fixture -> Html Msg
fixtureList fixtures =
  div []
    (List.map fixtureView fixtures)

fixtureView: Fixture -> Html Msg
fixtureView fixture =
    div [][
      div[][
        text fixture.date
      ]
    , div[][
        text fixture.homeTeamName, text <| toString fixture.result.goalsHomeTeam
      ]
    , div[][
         text fixture.awayTeamName, text <| toString fixture.result.goalsAwayTeam
      ]
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
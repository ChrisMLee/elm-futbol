import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode
import Json.Decode exposing (..)
import Json.Decode.Pipeline
import Http
import Task exposing (..)
import Date.Extra.Core exposing (monthToInt)

import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings)

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
    , error: String
    , date : Maybe Date
    , datePicker : DatePicker.DatePicker
    }

type alias League =
    { name : String
    , checked : Bool
    , id: Int
    }

type alias Fixture =
    { links : FixtureLinks
    , date : String
    , status : String
    , matchday : Int
    , homeTeamName : String
    , awayTeamName : String
    , result : FixtureResult
    , competition : Int
    }

type alias FixtureLinksSelf =
    { href : String
    }

type alias FixtureLinksCompetition =
    { href : String
    }

type alias FixtureLinksHomeTeam =
    { href : String
    }

type alias FixtureLinksAwayTeam =
    { href : String
    }

type alias FixtureLinks =
    { self : FixtureLinksSelf
    , competition : FixtureLinksCompetition
    , homeTeam : FixtureLinksHomeTeam
    , awayTeam : FixtureLinksAwayTeam
    }

type alias FixtureResultHalfTime =
    { goalsHomeTeam : Int
    , goalsAwayTeam : Int
    }

type alias FixtureResult =
    { goalsHomeTeam : Maybe Int
    , goalsAwayTeam : Maybe Int
    , halfTime : FixtureResultHalfTime
    }

type alias Competitions = List String
type alias StartTime = String
type alias EndTime = String
type alias Season = String
type alias Url = String


decodeFixture : Json.Decode.Decoder Fixture
decodeFixture =
    Json.Decode.Pipeline.decode Fixture
        |> Json.Decode.Pipeline.required "links" (decodeFixtureLinks)
        |> Json.Decode.Pipeline.required "date" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "status" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "matchday" (Json.Decode.int)
        |> Json.Decode.Pipeline.required "homeTeamName" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "awayTeamName" (Json.Decode.string)
        |> Json.Decode.Pipeline.required "result" (decodeFixtureResult)
        |> Json.Decode.Pipeline.required "competition" (Json.Decode.int)

decodeFixtureLinksSelf : Json.Decode.Decoder FixtureLinksSelf
decodeFixtureLinksSelf =
    Json.Decode.Pipeline.decode FixtureLinksSelf
        |> Json.Decode.Pipeline.required "href" (Json.Decode.string)

decodeFixtureLinksCompetition : Json.Decode.Decoder FixtureLinksCompetition
decodeFixtureLinksCompetition =
    Json.Decode.Pipeline.decode FixtureLinksCompetition
        |> Json.Decode.Pipeline.required "href" (Json.Decode.string)

decodeFixtureLinksHomeTeam : Json.Decode.Decoder FixtureLinksHomeTeam
decodeFixtureLinksHomeTeam =
    Json.Decode.Pipeline.decode FixtureLinksHomeTeam
        |> Json.Decode.Pipeline.required "href" (Json.Decode.string)

decodeFixtureLinksAwayTeam : Json.Decode.Decoder FixtureLinksAwayTeam
decodeFixtureLinksAwayTeam =
    Json.Decode.Pipeline.decode FixtureLinksAwayTeam
        |> Json.Decode.Pipeline.required "href" (Json.Decode.string)

decodeFixtureLinks : Json.Decode.Decoder FixtureLinks
decodeFixtureLinks =
    Json.Decode.Pipeline.decode FixtureLinks
        |> Json.Decode.Pipeline.required "self" (decodeFixtureLinksSelf)
        |> Json.Decode.Pipeline.required "competition" (decodeFixtureLinksCompetition)
        |> Json.Decode.Pipeline.required "homeTeam" (decodeFixtureLinksHomeTeam)
        |> Json.Decode.Pipeline.required "awayTeam" (decodeFixtureLinksAwayTeam)

decodeFixtureResultHalfTime : Json.Decode.Decoder FixtureResultHalfTime
decodeFixtureResultHalfTime =
    Json.Decode.Pipeline.decode FixtureResultHalfTime
        |> Json.Decode.Pipeline.required "goalsHomeTeam" (Json.Decode.int)
        |> Json.Decode.Pipeline.required "goalsAwayTeam" (Json.Decode.int)

decodeFixtureResult : Json.Decode.Decoder FixtureResult
decodeFixtureResult =
    Json.Decode.Pipeline.decode FixtureResult
        |> Json.Decode.Pipeline.required "goalsHomeTeam" (Json.Decode.nullable Json.Decode.int)
        |> Json.Decode.Pipeline.required "goalsAwayTeam" (Json.Decode.nullable Json.Decode.int)
        |> Json.Decode.Pipeline.optional "halfTime" (decodeFixtureResultHalfTime) ({ goalsHomeTeam = 0
    , goalsAwayTeam = 0})

fixtureListDecoder : Json.Decode.Decoder (List Fixture)
fixtureListDecoder = Json.Decode.list decodeFixture

init : (Model, Cmd Msg)
init =
  let 
     ( datePicker, datePickerFx ) = DatePicker.init defaultSettings
  in
  ((Model [ { name = "Premier League", checked = True, id = 426}
              , { name = "La Liga", checked = True, id = 436}
              , { name = "Bundesliga", checked = True, id = 430}
              , { name = "Serie A", checked = True, id = 438}
              , { name = "Champions League", checked = True, id = 440}
    ] [{
    links= {
      self= {
        href= "http://api.football-data.org/v1/fixtures/152161"
      },
      competition= {
        href= "http://api.football-data.org/v1/competitions/430"
      },
      homeTeam= {
        href= "http://api.football-data.org/v1/teams/3"
      },
      awayTeam= {
        href= "http://api.football-data.org/v1/teams/721"
      }
    },
    date= "2016-11-18T19:30:00Z",
    status= "FINISHED",
    matchday= 11,
    homeTeamName= "Bayer Leverkusen",
    awayTeamName= "Red Bull Leipzig",
    result= {
      goalsHomeTeam= (Just 2),
      goalsAwayTeam= (Just 3),
      halfTime= {
        goalsHomeTeam= 2,
        goalsAwayTeam= 1
      }
    },
    competition= 430
  }] "No Error" Nothing datePicker), Cmd.batch[ Cmd.map ToDatePicker datePickerFx ])

-- The exclamation point in model ! [] is just a short-hand function for (model, Cmd.batch []), 
-- which is the type returned from typical update statements

-- UPDATE
type Msg
    = Check Int Bool
    | ErrorOccurred Http.Error
    | DataFetched (List Fixture)
    | FetchFixtures (Maybe Date)
    | ToDatePicker DatePicker.Msg

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

      DataFetched fetchedFixtures ->
        ({model | fixtures = fetchedFixtures}, Cmd.none)

      ErrorOccurred err ->
        ({model | error = (toString err)}, Cmd.none)

      FetchFixtures mDate ->
            let
              action = 
                case mDate of
                    Nothing -> 
                      Cmd.none
                    Just date ->
                      let 
                        leagueIdList = List.map toString << List.map (\league -> league.id) <| model.leagues
                        url = makeFixtureUrl "2016" "2016-11-14" "2016-11-28" leagueIdList
                      in
                        getFixtures url
            in 
              (model, action)

      ToDatePicker msg ->
            let
                ( newDatePicker, datePickerFx, mDate ) =
                    DatePicker.update msg model.datePicker
                one = Debug.log "date" date
                date =
                    case mDate of
                        Nothing ->
                            model.date

                        date ->
                            date

                fetchAction = 
                    case mDate of
                        Nothing -> 
                          Cmd.none
                        Just date ->
                          let
                            five =  Debug.log "formatted" (formatIncomingDate date)
                            formattedDate = formatIncomingDate date
                            leagueIdList = List.map toString << List.map (\league -> league.id) <| model.leagues
                            url = makeFixtureUrl (toString <| year date) formattedDate formattedDate leagueIdList
                          in
                            getFixtures url
            in
                { model
                    | date = date
                    , datePicker = newDatePicker
                }
                    ! [ Cmd.map ToDatePicker datePickerFx,  fetchAction ]

boolToString : Bool -> String 
boolToString x = if x then " True" else " False"

-- VIEW

view : Model -> Html Msg
view model =
    let
      checkedLeagues = List.map .id <| List.filter .checked model.leagues

      --_ = Debug.log "checkedLeagues" <| toString checkedLeagues
      visibleFixtures = List.filter (\x -> List.member x.competition checkedLeagues) model.fixtures
      --_ = Debug.log "visibleFixtures" <| toString visibleFixtures
    in 
    div []
        [ 
            datePickerView model.date model.datePicker
          , checkboxList model
          , div []
            [
              text model.error
            ]
          , fixtureList visibleFixtures
        ]

datePickerView : Maybe Date -> DatePicker.DatePicker -> Html Msg 
datePickerView date datePicker = div []
                     [ case date of
                          Nothing ->
                              h1 [] [ text "Pick a date" ]

                          Just date ->
                              h1 [] [ text <| formatDate date ]
                      , DatePicker.view datePicker
                          |> Html.map ToDatePicker
                      ]

formatDate : Date -> String
formatDate d =
    toString (month d) ++ " " ++ toString (day d) ++ ", " ++ toString (year d)

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

-- HTTP

makeFixtureUrl : Season -> StartTime -> EndTime -> Competitions -> Url
makeFixtureUrl season starttime endtime competitions = 
  "http://localhost:8080/fixtures/" ++ season 
                                    ++ "/"
                                    ++ starttime
                                    ++ "/"
                                    ++ endtime 
                                    ++ "?" 
                                    ++ "competitions="
                                    ++ String.join "," competitions

getFixtures: Url -> Cmd Msg
getFixtures url =
  Http.send updateFixtures (Http.get url fixtureListDecoder)

updateFixtures result =
    case result of
        Err err -> 
            ErrorOccurred err 
        Ok val ->
            DataFetched val 
        

-- Helpers

formatIncomingDate : Date -> String
formatIncomingDate date = String.join "-" [ (toString <| year date), (twoDigit <| monthToInt <| month date), (twoDigit <|day date)]

twoDigit : Int -> String
twoDigit int = if int > 9 then toString <| int else "0" ++ (toString <| int)


--update : Msg -> Model -> (Model, Cmd Msg)
--update msg model =
--  case msg of
--    FetchData num->
--      (model, fetchData num)
--    DataFetched fetchedFixtures ->
--      log (toString fetchedFixtures)
--      ({model | currentFixtures = (Just fetchedFixtures)}, Cmd.none)
--    ErrorOccurred _ ->
--      log ("error occured")
--      (model, Cmd.none)


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
module Main (TemplateTag, templateTags, getRequestOptions) where

import Control.Plus (empty)
import Data.Bounded (bottom)
import Data.DateTime.Instant (instant, toDateTime)
import Data.Formatter.DateTime (Formatter, FormatterCommand(..), format) as Fmt
import Data.Function (($))
import Data.Generic (class Generic, gShow)
import Data.List.Types
import Data.Maybe (fromMaybe)
import Data.Ring ((-))
import Data.Semigroup ((<>))
import Data.Semiring ((*))
import Data.Show (class Show, show)
import Data.String (null)
import Data.Time.Duration (Milliseconds(..))


-- TODO: Use request as foreign function
-- foreign import data HTTP :: Effect
-- foreign import getRunImpl :: forall eff . Fn3
--   RequestOptions
--   (String -> Eff (http :: HTTP | eff) Unit)
--   (ErrorCode -> Eff (http :: HTTP | eff) Unit)
--   (Eff (http :: HTTP | eff) Unit)

-- type Async eff = ContT Unit (Eff eff)
-- fetch :: forall eff.
--   RequestOptions -> Async (http :: HTTP | eff) (Either String String)
-- fetch options = ContT
--   \k -> runFn3 getRunImpl options (k <<< Right) (k <<< Left)

-- fetchPromise :: forall eff.
--   Async (http :: HTTP | eff) (Promise (Either String String))
-- fetchPromise = fromAff fetch

-- TODO:
-- type RunFunction = forall eff. Fn3 Context Token QueryString
--   (ExceptT ErrorCode (Async (http :: HTTP | eff)) String)


type QueryString = String
type ErrorCode = String
type QueryObject =
  { q :: QueryString
  , sort :: String
  , order :: String
  , per_page :: Int
  }
type RequestOptions =
  { uri :: String
  , qs :: QueryObject
  , headers ::
    { "User-Agent" :: String
    , "Authorization" :: String -- TODO: Use `Maybe`
    }
  }

newtype Arg = Arg {
    displayName :: String,
    description :: String,
    type :: String,
    defaultValue :: String
  }

derive instance genericArg :: Generic Arg
instance showArg :: Show Arg where
    show = gShow

newtype TemplateTag = TemplateTag
  { name :: String
  , displayName :: String
  , description :: String
  , args :: Array Arg
  , run :: RunFunction
  }

type Context = { todo :: String }
type Token = String
type FullName = String
type MaxNumberOfStars = Int
type DateNow = Number -- Value from JavaScript's Date.now()
type RunFunction = Context -> Token -> QueryString -> FullName


maxNumberOfStars :: MaxNumberOfStars
maxNumberOfStars = 1000


getQueryObject
  :: QueryString
  -> MaxNumberOfStars
  -> Milliseconds
  -> QueryObject
getQueryObject queryString maxStars now =
  let
    formatter :: Fmt.Formatter
    formatter = Fmt.YearFull : (Fmt.Placeholder "-")
      : Fmt.MonthTwoDigits : (Fmt.Placeholder "-")
      : Fmt.DayOfMonthTwoDigits : (Fmt.Placeholder "T")
      : Fmt.Hours24 : (Fmt.Placeholder ":")
      : Fmt.MinutesTwoDigits : (Fmt.Placeholder ":")
      : Fmt.SecondsTwoDigits
      : empty

    msPerHour = 3600000.0
    shortDur = Milliseconds (5.0 * msPerHour)
    longDur = Milliseconds (6.0 * msPerHour)
    nowInstant = toDateTime $ fromMaybe bottom (instant (now - shortDur))
    earlierInstant =  toDateTime
      $ fromMaybe bottom $ instant $ now - longDur

    queryStringTemp = if null queryString
      then
        "size:<" <> (show maxStars) <> " " <>
        "pushed:\"" <> (Fmt.format formatter earlierInstant)
          <> " .. " <> (Fmt.format formatter nowInstant)
          <> "\""
      else queryString

  in
    { q: queryStringTemp
    , sort: "updated"
    , order: "desc"
    -- GitHub does not support searching for a random repo
    -- therefore get several and randomly pick one
    , per_page: 100
    }


getRequestOptions :: Token -> QueryString -> DateNow -> RequestOptions
getRequestOptions token queryString now =
  { uri: "https://api.github.com/search/repositories"
  , headers:
    { "User-Agent": "feram"
    , "Authorization": if null token then "" else "token " <> token
    }
  , qs: getQueryObject queryString maxNumberOfStars (Milliseconds now)
  }


run :: RunFunction
run context token queryString =
  "TODO: Implement it (gets currently overwritten in index.js)"
  -- run = mkFn3 \context token queryString ->
  --   "TODO"
  --   let
  --     searchResponse = await request(requestOptions)
  --     searchObject = JSON.parse(searchResponse)
  --     selectedRepo = sample(searchObject.items)
  --   in
  --     fetch (getRequestOptions token queryString)
  --     fetchPromise requestOptions
  --     selectedRepo.full_name


templateTags :: Array TemplateTag
templateTags =
  [ TemplateTag
    { name: "RandomRepo"
    , displayName: "Random Repo"
    , description: "Get a random GitHub repo name"
    , run: run
    , args:
      [ Arg
        { displayName: "Authorization Token"
        , description: "Token to increase rate limit for search queries"
        , type: "string"
        , defaultValue: ""
        }
      , Arg
        { displayName: "Search String"
        , description: """
            Explicit search string instead of one for a random repo
          """
        , type: "string"
        , defaultValue: ""
        }
      ]
    }
  ]

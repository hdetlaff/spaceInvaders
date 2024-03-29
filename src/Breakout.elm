module Breakout exposing (..)

import Playground exposing (..)
import Random
import Set
import Time as PosixTime


-- PHYSICS PARAMETERS

brickCount = 100
ballRadius = 7
paddleHeight = 14
paddleWidth = 70
ballSpeed = 5
ballColor = (rgb 160 160 160)
paddleColor = (rgb 255 120 60)
brickColor = blue
gameWidth = 600
gameHeight = 700
brickWidth = 54
brickHeight = 16
marginSize = 5
initBallX = 0
initBallY = -99

-- MAIN

main = game view update initialState

type alias GameObject =
  { x : Float
  , y : Float
  , dx : Float
  , dy : Float
  , collidedHoriz : Bool
  , collidedVert: Bool
  , shape : List (Float, Float)
  }

type alias Model =
  { ball : GameObject
  , paddle : GameObject
  , bricks : List GameObject
  , lives: List GameObject
  }

initialState : Model
initialState =
  { ball = { x = initBallX, y = initBallY, dx = 3, dy = 3, collidedHoriz = False, collidedVert = False, shape = ballShape}
  , paddle = { x = 0, y = -300, dx = 0, dy = 0, collidedHoriz = False, collidedVert = False, shape = paddleShape}
  , bricks = makeBricks
  , lives = makeLives 3
  }

ballShape =
  [ (-ballRadius, -ballRadius)
  , (-ballRadius, ballRadius)
  , (ballRadius, ballRadius)
  , (ballRadius, -ballRadius)
  ]

paddleShape =
  [ (-paddleWidth/2, -paddleHeight/2)
  , (-paddleWidth/2, paddleHeight/2)
  , (paddleWidth/2, paddleHeight/2)
  , (paddleWidth/2, -paddleHeight/2)
  ]

brickShape =
  [ (-brickWidth/2, -brickHeight/2)
  , (-brickWidth/2, brickHeight/2)
  , (brickWidth/2, brickHeight/2)
  , (brickWidth/2, -brickHeight/2)
  ]

makeLives numLives =
  List.map makeLife (List.range 0 (numLives-1))

makeLife index =
  { x = toFloat ((remainderBy 3 index) * (ballRadius*2 + marginSize) - 280)
  , y =  -330
  , dx = 0
  , dy = 0
  , collidedHoriz = False
  , collidedVert = False
  , shape = ballShape
  }

makeBricks =
  List.map makeBrick (List.range 0 (brickCount - 1))

makeBrick index =
  { x = toFloat ((remainderBy 10 index) * (brickWidth + marginSize) - 266)
  , y =  toFloat ((index // 10) * (brickHeight + marginSize) + 50)
  , dx = 0
  , dy = 0
  , collidedHoriz = False
  , collidedVert = False
  , shape = brickShape
  }

-- VIEW

view computer model =
  [rectangle black gameWidth gameHeight]
    ++ [(model.ball   |> viewGameObject ballColor)]
    ++ [(model.paddle |> viewGameObject paddleColor)]
    ++ (model.bricks  |> List.map (viewGameObject brickColor))
    ++ (model.lives   |> List.map (viewGameObject ballColor))

viewGameObject : Color -> GameObject -> Shape -- took out Float
viewGameObject color obj =
  polygon color obj.shape
    |> fade 1.0 --opacity
    |> move obj.x obj.y


-- UPDATE

update computer model =
  model
     |> ballMotion
     |> paddleMotion computer
     |> checkCollisions
     |> checkDeath

checkDeath model =
  if model.ball.y < model.paddle.y - paddleHeight/2 && (List.length model.lives) > 0 then
    { ball = {x = initBallX, y = initBallY, dx = 3, dy = 3, collidedHoriz = False, collidedVert = False, shape = ballShape}
    , paddle = model.paddle
    , bricks = model.bricks
    , lives = makeLives ((List.length model.lives)-1)
    }
  else if model.ball.y < model.paddle.y - paddleHeight/2 && (List.isEmpty model.lives) then
    initialState
  else
   model

paddleMotion computer model =
  if computer.mouse.x > (-305 + paddleWidth/2) &&  computer.mouse.x < (305 - paddleWidth/2) then
     { ball = model.ball
     , paddle = {x = computer.mouse.x, y = -300, dx = 0, dy = 0, collidedHoriz = False, collidedVert = False, shape = paddleShape}
     , bricks = model.bricks
     , lives = model.lives
     }
  else
    model

paddleCollision model =
 if model.ball.y <= (model.paddle.y + paddleHeight )
   && model.ball.x >= model.paddle.x - paddleWidth/2
   && model.ball.x <= model.paddle.x + paddleWidth/2 then
     verticalBounce model
 else
   model

wallCollision model =
  if model.ball.x + ballRadius > gameWidth/2  || model.ball.x - ballRadius < -1*(gameWidth/2 ) then
     horizontalBounce model
  else if model.ball.y + ballRadius > gameHeight/2  || model.ball.y < -1*(gameHeight/2 - ballRadius/2) then
     verticalBounce model
  else
    model

checkBrick ball brick =
  if (ball.x - ballRadius >= brick.x - brickWidth/2
   && ball.x + ballRadius <= brick.x + brickWidth/2
   && ball.y - ballRadius >= brick.y - brickWidth/2
   && ball.y + ballRadius <= brick.y + brickWidth/2)
   || (ball.x - ballRadius >= brick.x - brickWidth/2
   && ball.x + ballRadius<= brick.x + brickWidth/2
   && ball.y - ballRadius >= brick.y - brickWidth/2
   && ball.y + ballRadius <= brick.y + brickWidth/2) then
     { brick | collidedVert = True }
  else if (ball.x + ballRadius >= brick.x - brickWidth/2
   && ball.x + ballRadius <= brick.x + brickWidth/2
   && ball.y - ballRadius >= brick.y - brickWidth/2
   && ball.y + ballRadius <= brick.y + brickWidth/2)
   || (ball.x - ballRadius >= brick.x - brickWidth/2
   && ball.x + ballRadius <= brick.x + brickWidth/2
   && ball.y - ballRadius>= brick.y - brickWidth/2
   && ball.y + ballRadius <= brick.y + brickWidth/2) then
     { brick | collidedHoriz = True }
  else
    brick

brickCollision model =
  { ball = model.ball
  , paddle = model.paddle
  , bricks = List.map (checkBrick model.ball) model.bricks
  , lives = model.lives
  }

brickRemove model =
  { ball =  brickBounce model.ball model.bricks
  , paddle = model.paddle
  , bricks = List.filter (\b -> not (isCollidedHoriz b || isCollidedVert b)) model.bricks
  , lives = model.lives
  }

brickBounce ball bricks =
  if List.any isCollidedVert bricks then
    { ball | dy = -1 * ball.dy }
  else if List.any isCollidedHoriz bricks then
    { ball | dx = -1 * ball.dx }
  else
    ball

isCollidedHoriz brick =
  brick.collidedHoriz

isCollidedVert brick =
  brick.collidedVert

horizontalBounce model =
  { ball = { x = model.ball.x
           , y = model.ball.y
           , dx = -1 * model.ball.dx
           , dy = model.ball.dy
           , collidedHoriz = False
           , collidedVert = False
           , shape = ballShape
           }
  , paddle = model.paddle
  , bricks = model.bricks
  , lives = model.lives
  }
verticalBounce model =
  { ball = { x = model.ball.x
           , y = model.ball.y
           , dx = model.ball.dx
           , dy = -1 * model.ball.dy
           , collidedHoriz = False
           , collidedVert = False
           , shape = ballShape
           }
  , paddle = model.paddle
  , bricks = model.bricks
  , lives = model.lives
  }

checkCollisions model =
  model
    |> paddleCollision
    |> wallCollision
    |> brickCollision
    |> brickRemove

ballMotion model =
  { ball = { x = model.ball.x + model.ball.dx
           , y = model.ball.y + model.ball.dy
           , dx = model.ball.dx
           , dy = model.ball.dy
           , collidedHoriz = False
           , collidedVert = False
           , shape = ballShape
           }
  , paddle = model.paddle
  , bricks = model.bricks
  , lives = model.lives
  }

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
gameHeight = 800
brickWidth = 54
brickHeight = 16
marginSize = 5

-- MAIN

main = game view update initialState

type alias GameObject =
  { x : Float
  , y : Float
  , dx : Float
  , dy : Float
  , collided : Bool
  , shape : List (Float, Float)
  }

type alias Model =
  { ball : GameObject
  , paddle : GameObject
  , bricks : List GameObject
  }

initialState : Model
initialState =
  { ball = { x = 0, y = -100, dx = 3, dy = 3, collided = False, shape = ballShape}
  , paddle = { x = 0, y = -300, dx = 0, dy = 0, collided = False, shape = paddleShape}
  , bricks = makeBricks
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

makeBricks =
  List.map makeBrick (List.range 0 (brickCount - 1))

makeBrick index =
  { x = toFloat ((remainderBy 10 index) * (brickWidth + marginSize) - 266)
  , y =  toFloat ((index // 10) * (brickHeight + marginSize) + 50)
  , dx = 0
  , dy = 0
  , collided = False
  , shape = brickShape
  }

-- VIEW

view computer model =
  [rectangle black gameWidth gameHeight]
    ++ [(model.ball      |> viewGameObject ballColor)]
    ++ [(model.paddle |> viewGameObject paddleColor)]
    ++ (model.bricks   |> List.map (viewGameObject brickColor))

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

paddleMotion computer model =
  if computer.mouse.x > (-305 + paddleWidth/2) &&  computer.mouse.x < (305 - paddleWidth/2) then
     { ball = model.ball
     , paddle = {x = computer.mouse.x, y = -300, dx = 0, dy = 0, collided = False, shape = paddleShape}
     , bricks = model.bricks
     }
  else
    model

paddleCollision model =
 if model.ball.y <= model.paddle.y + paddleHeight/2
   && model.ball.x >= model.paddle.x - paddleWidth/2
   && model.ball.x <= model.paddle.x + paddleWidth/2 then
     verticalBounce model
 else
   model

wallCollision model =
  if model.ball.x > gameWidth/2 + ballRadius/2 || model.ball.x < -1*(gameWidth/2 - ballRadius/2) then
     horizontalBounce model
  else if model.ball.y > gameHeight/2 + ballRadius/2 || model.ball.y < -1*(gameHeight/2 - ballRadius/2) then
     verticalBounce model
  else
    model

checkBrick model brick =
  if model.ball.x >= brick.x - brickWidth/2
    && model.ball.x <= brick.x + brickWidth/2
    && model.ball.y  >= brick.y - brickWidth/2
    && model.ball.y  <= brick.y + brickWidth/2 then
     { brick | x = -1000, y = -1000, collided = True }
  else
    brick

brickCollision model =
  { ball =  model.ball
  , paddle = model.paddle
  , bricks = List.map (checkBrick model) model.bricks
  }

--brickBounce model ball =
--  if List.any model.bricks.collided == True  model.bricks then
--    {ball | dy = -1 * ball.dy}
--  else
--    ball


horizontalBounce model =
  { ball = { x = model.ball.x
           , y = model.ball.y
           , dx = -1 * model.ball.dx
           , dy = model.ball.dy
           , collided = False
           , shape = ballShape
           }
  , paddle = model.paddle
  , bricks = model.bricks
  }
verticalBounce model =
  { ball = { x = model.ball.x
           , y = model.ball.y
           , dx = model.ball.dx
           , dy = -1 * model.ball.dy
           , collided = False
           , shape = ballShape
           }
  , paddle = model.paddle
  , bricks = model.bricks
  }

checkCollisions model =
  model
    |> paddleCollision
    |> wallCollision
    |> brickCollision

ballMotion model =
  { ball = { x = model.ball.x + model.ball.dx
           , y = model.ball.y + model.ball.dy
           , dx = model.ball.dx
           , dy = model.ball.dy
           , collided = False
           , shape = ballShape
           }
   , paddle = model.paddle
   , bricks = model.bricks
   }
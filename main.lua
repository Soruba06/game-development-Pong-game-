-- GD50 2018 Pong Remake
push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
PADDLE_SPEED = 200

-- Control Settings
CONFIG = {
    ballSize = 4,
    ballSpeed = 200,
    paddleHeight = 20,
    paddleSpeed = PADDLE_SPEED
}

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Pong')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, resizable = true, vsync = true
    })

    player1 = Paddle(10, 30, 5, CONFIG.paddleHeight)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, CONFIG.paddleHeight)
    ball = Ball(VIRTUAL_WIDTH / 2 - CONFIG.ballSize / 2, VIRTUAL_HEIGHT / 2 - CONFIG.ballSize / 2, CONFIG.ballSize, CONFIG.ballSize)

    player1Score = 0
    player2Score = 0
    servingPlayer = 1
    winningPlayer = 0
    gameState = 'start'

    isPaused = false
    darkMode = true
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if not isPaused then
        if gameState == 'serve' then
            ball.dy = math.random(-50, 50)
            if servingPlayer == 1 then
                ball.dx = math.random(140, CONFIG.ballSpeed)
            else
                ball.dx = -math.random(140, CONFIG.ballSpeed)
            end
        elseif gameState == 'play' then
            if ball:collides(player1) then
                ball.dx = -ball.dx * 1.03
                ball.x = player1.x + player1.width
                ball.dy = ball.dy < 0 and -math.random(10, 150) or math.random(10, 150)
                player1:flash()
                sounds['paddle_hit']:play()
            end
            if ball:collides(player2) then
                ball.dx = -ball.dx * 1.03
                ball.x = player2.x - ball.width
                ball.dy = ball.dy < 0 and -math.random(10, 150) or math.random(10, 150)
                player2:flash()
                sounds['paddle_hit']:play()
            end
            if ball.y <= 0 then
                ball.y = 0
                ball.dy = -ball.dy
                sounds['wall_hit']:play()
            end
            if ball.y >= VIRTUAL_HEIGHT - ball.height then
                ball.y = VIRTUAL_HEIGHT - ball.height
                ball.dy = -ball.dy
                sounds['wall_hit']:play()
            end
            if ball.x < 0 then
                servingPlayer = 1
                player2Score = player2Score + 1
                sounds['score']:play()
                gameState = player2Score == 10 and 'done' or 'serve'
                if gameState == 'serve' then ball:reset() end
            end
            if ball.x > VIRTUAL_WIDTH then
                servingPlayer = 2
                player1Score = player1Score + 1
                sounds['score']:play()
                gameState = player1Score == 10 and 'done' or 'serve'
                if gameState == 'serve' then ball:reset() end
            end
        end

        if love.keyboard.isDown('w') then player1.dy = -CONFIG.paddleSpeed
        elseif love.keyboard.isDown('s') then player1.dy = CONFIG.paddleSpeed else player1.dy = 0 end
        if love.keyboard.isDown('up') then player2.dy = -CONFIG.paddleSpeed
        elseif love.keyboard.isDown('down') then player2.dy = CONFIG.paddleSpeed else player2.dy = 0 end

        if gameState == 'play' then ball:update(dt) end
        player1:update(dt)
        player2:update(dt)
    end
end

function love.keypressed(key)
    if key == 'escape' then love.event.quit() end
    if key == 'enter' or key == 'return' then
        if gameState == 'start' then gameState = 'serve'
        elseif gameState == 'serve' then gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()
            player1Score, player2Score = 0, 0
            servingPlayer = winningPlayer == 1 and 2 or 1
        end
    elseif key == 'p' then isPaused = not isPaused
    elseif key == 'm' then darkMode = not darkMode
    elseif key == 'b' then
        CONFIG.ballSize = CONFIG.ballSize + 1
        ball.width = CONFIG.ballSize
        ball.height = CONFIG.ballSize
    elseif key == 'n' then
        CONFIG.ballSize = math.max(2, CONFIG.ballSize - 1)
        ball.width = CONFIG.ballSize
        ball.height = CONFIG.ballSize
    elseif key == 'k' then CONFIG.ballSpeed = CONFIG.ballSpeed + 10
    elseif key == 'l' then CONFIG.ballSpeed = math.max(50, CONFIG.ballSpeed - 10)
    elseif key == 'p' then CONFIG.paddleSpeed = CONFIG.paddleSpeed + 10
    elseif key == 'o' then CONFIG.paddleSpeed = math.max(50, CONFIG.paddleSpeed - 10)
    elseif key == 'z' then
        CONFIG.paddleHeight = CONFIG.paddleHeight + 2
        player1.height = CONFIG.paddleHeight
        player2.height = CONFIG.paddleHeight
    elseif key == 'x' then
        CONFIG.paddleHeight = math.max(5, CONFIG.paddleHeight - 2)
        player1.height = CONFIG.paddleHeight
        player2.height = CONFIG.paddleHeight
    end
end

function love.draw()
    push:apply('start')

    if darkMode then love.graphics.clear(0.1, 0.1, 0.1, 1)
    else love.graphics.clear(1, 1, 1, 1) end

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    displayScore()
    player1:render()
    player2:render()
    ball:render()
    displayControls()

    if isPaused then
        love.graphics.setFont(largeFont)
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press 'P' to resume", 0, VIRTUAL_HEIGHT / 2 + 10, VIRTUAL_WIDTH, "center")
    end

    displayFPS()
    push:apply('end')
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

function displayControls()
    love.graphics.setFont(smallFont)
    love.graphics.printf("CONTROLS:", 0, VIRTUAL_HEIGHT - 80, VIRTUAL_WIDTH, "center")
    love.graphics.printf("B/N = Ball size | K/L = Ball speed | P/O = Paddle speed", 0, VIRTUAL_HEIGHT - 70, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Z/X = Paddle height | M = Dark Mode | P = Pause", 0, VIRTUAL_HEIGHT - 60, VIRTUAL_WIDTH, "center")
    love.graphics.printf("ESC = Quit | ENTER = Start/Serve", 0, VIRTUAL_HEIGHT - 50, VIRTUAL_WIDTH, "center")
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end

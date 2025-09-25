--[[
    GD50 2018
    Pong Remake

    -- Paddle Class --

    Modified with "flash on hit" effect
]]

Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0

    self.color = {1, 1, 1} -- default white

    -- effect timer (when > 0, paddle glows bright)
    self.flashTimer = 0
end

function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end

    -- reduce flash timer over time
    if self.flashTimer > 0 then
        self.flashTimer = math.max(0, self.flashTimer - dt)
    end
end

-- Call this when the paddle hits the ball
function Paddle:flash()
    self.flashTimer = 0.2 -- paddle glows bright for 0.2 seconds
end

function Paddle:setColor(r, g, b)
    self.color = {r, g, b}
end

function Paddle:render()
    if self.flashTimer > 0 then
        -- Bright yellow paddle when flashing
        love.graphics.setColor(1, 1, 0.5, 1)
    else
        love.graphics.setColor(self.color)
    end

    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

    -- reset color
    love.graphics.setColor(1, 1, 1, 1)
end

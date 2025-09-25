Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.dy = 0
    self.dx = 0

    -- bounce effect variables
    self.bounceTimer = 0
    self.bounceDuration = 0.1
    self.bounceSize = 1
end

function Ball:collides(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    -- trigger bounce effect on collision
    self:bounce()
    return true
end

function Ball:bounce()
    self.bounceTimer = self.bounceDuration
    self.bounceSize = 2 -- enlarge the ball briefly
end

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = 0
    self.dy = 0
    self.bounceTimer = 0
    self.bounceSize = 1
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- shrink back to normal size after bounce
    if self.bounceTimer > 0 then
        self.bounceTimer = math.max(0, self.bounceTimer - dt)
        if self.bounceTimer == 0 then
            self.bounceSize = 1 --change---
        end
    end
end

function Ball:render()
    local cx = self.x + self.width / 2
    local cy = self.y + self.height / 2
    local radius = (self.width / 2) * self.bounceSize

    -- Neon glow effect
    for i = 1, 4 do
        love.graphics.setColor(1, 0, 0, 0.15 / i)
        love.graphics.circle("fill", cx, cy, radius + (i * 2))
    end

    -- Main ball
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.circle("fill", cx, cy, radius)

    love.graphics.setColor(1, 1, 1, 1)
end

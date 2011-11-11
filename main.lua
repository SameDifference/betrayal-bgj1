function love.load()
   player = love.graphics.newImage("player.png")
   x = 50
   y = love.graphics.getHeight() - player:getHeight()
   speed = 100
end

function love.update(dt)
   if love.keyboard.isDown("right") then
      x = x + (speed * dt)
   elseif love.keyboard.isDown("left") then
      x = x - (speed * dt)
   end

   if love.keyboard.isDown("space") then
      for bullet in bullets do
          
      end
   end
end

function love.draw()
   love.graphics.draw(player, x, y)
end

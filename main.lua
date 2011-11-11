function love.load()
   player = love.graphics.newImage("player.png")
   x = 50
   y = love.graphics.getHeight() - player:getHeight()
   bullets = { {} }
   bullet_count = 0
   is_reloading = 0
   speed = 100
end

function love.update(dt)
   if love.keyboard.isDown("right") then
      x = x + (speed * dt)
   elseif love.keyboard.isDown("left") then
      x = x - (speed * dt)
   end

   if is_reloading > 0 then
       is_reloading = is_reloading - dt
       if is_reloading < 0 then
           print("done reloading")
           is_reloading = 0
       end
   end

   if love.keyboard.isDown("space") then
   --   bullet_count += 1
   --   if bullet_count > 30 then
   --      is_reloading = 1
   --      print("reloading")
   --   end
   end

--   if love.keyboard.isDown("z") then
--      if is_reloading = 0 then
--         is_reloading = 1
--         print("reloading")
--      end
--   end
end

function love.draw()
   love.graphics.draw(player, x, y)
end

function love.load()
   love.graphics.setCaption("BaconGameJam 1")
   player = love.graphics.newImage("player.png")
   x = 50
   y = love.graphics.getHeight() - player:getHeight()
   bullets = { {} }
   bullet_count = 1
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
           bullet_count = 1
       end
   end

   if love.keyboard.isDown(" ") then
      if is_reloading == 0 then
         bullet_count = bullet_count + 1
         print("fire")
         if bullet_count > 30 then
            is_reloading = 1
            print("reloading")
         end
      end
   end

   if love.keyboard.isDown("z") then
      if is_reloading == 1 then
         is_reloading = 1
         print("reloading")
      end
   end
end

function love.draw()
   love.graphics.draw(player, x, y)
   info = 30 - bullet_count + 1 .. "/" .. 30
   love.graphics.print(info, 0, 0)
end

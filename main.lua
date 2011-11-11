function love.load()
   love.graphics.setCaption("BaconGameJam 1")
   player = love.graphics.newImage("player.png")
   x = 50
   y = love.graphics.getHeight() - player:getHeight()
   bullets = { {} }
   for i=1,60 do
       bullets[i] = {}
   end
   bullet_count = 60
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
           bullet_count = 60
       end
   end

   if love.keyboard.isDown(" ") then
      if is_reloading == 0 then
         bullet_count = bullet_count - 1
         bullets[bullet_count] = {}
         bullets[bullet_count].exists = 1
         bullets[bullet_count].x = x
         bullets[bullet_count].y = y 
         print("fire")
         if bullet_count < 1 then
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

   bullet_now = 0

   while bullet_now <= 60 do
      if bullets[bullet_now] ~= nil and bullets[bullet_now].exists == 1 then
         bullets[bullet_now].y = bullets[bullet_now].y - (dt * 300)
         if bullets[bullet_now].y < 0 then
            bullets[bullet_now].exists = 0
            print("bullet leaves")
         end
      end
      bullet_now = bullet_now + 1
   end
end

function love.draw()
   love.graphics.draw(player, x, y)
   info = bullet_count .. "/" .. 60 .. "\n" .. "Reloading: " .. is_reloading
   love.graphics.print(info, 0, 0)
end

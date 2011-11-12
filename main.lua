function love.load()
   love.graphics.setCaption("BaconGameJam 1")
   bg = love.graphics.newImage("sky.jpg")
   player = love.graphics.newImage("player.png")
   bullet = love.graphics.newImage("bullet.png")
   jackson = love.graphics.newImage("jackson.png")
   hall = love.graphics.newImage("hall.png")
   say_msg = {}
   conversation = 0
   x = 50
   y = love.graphics.getHeight() - player:getHeight()
   bullets = { {} }
   for i=1,60 do
       bullets[i] = {}
   end

   mines = { {} }

   bullet_count = 60
   is_reloading = 0
   speed = 100
   conv = {
      [1] = {"Delta X to Orange 3, do you copy?\n(Press s to skip!)", jackson},
      [9] = {"Orange 3 copies loud and clear Delta X over.", hall},
      [16] = {"Delta X to Orange 3 return time over.", jackson},
      [25] = {"Orange 3 to Delta X it's 11:11 11/11/11, do you copy?", hall},
      [32] = {"Delta X copies Orange 3, over.", jackson},
      [40] = {"*shuts down the radio*", jackson},
      [44] = {"I've spent so far, away from home.", jackson},
      [52] = {"So sad, so alone...", jackson},
      [61] = {"Delta X we have hostile movement in your area over!", hall},
      [70] = {"Copy that Orange 3, will take them out.", jackson},
      [80] = {nil, nil},
      [130] = {"Delta X skies are clear.", hall},
      [137] = {"But you, must die!", hall},
      [145] = {"I knew it Hall!", jackson}, --_alarm},
      [150] = {"It was not my order. But it must happen, die Jackson!", hall},
      [170] = {"Where am I...", jackson} --_bloody}
   }


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
           --print("done reloading")
           is_reloading = 0
           bullet_count = 60
       end
   end

   if love.keyboard.isDown(" ") then
      if is_reloading == 0 then
         bullet_count = bullet_count - 1
         bullets[bullet_count] = {}
         bullets[bullet_count].exists = 1
         bullets[bullet_count].x = x + (player:getWidth() / 2)
         bullets[bullet_count].y = y 
         --print("fire")
         if bullet_count < 1 then
            is_reloading = 1
            --print("reloading")
         end
      end
   end

   if love.keyboard.isDown("z") then
      if is_reloading == 0 then
         is_reloading = (.016666666) * ((bullet_count + 1) / 1.25)
         --print("reloading")
      end
   end

   bullet_now = 0

   while bullet_now <= 60 do
      if bullets[bullet_now] ~= nil and bullets[bullet_now].exists == 1 then
         bullets[bullet_now].y = bullets[bullet_now].y - (dt * 300)
         if bullets[bullet_now].y < 0 then
            bullets[bullet_now].exists = 0
            --print("bullet leaves")
         end
      end
      bullet_now = bullet_now + 1
   end

   conversation = conversation + dt
   if love.keyboard.isDown("s") then
      conversation = 70
   end

   if conv[math.floor(conversation)] ~= nil then
      say_msg = conv[math.floor(conversation)]
   end
end

function say(message, image)
   love.graphics.draw(image, 0, love.graphics.getHeight() - image:getHeight())
   love.graphics.setColor({0, 0, 0, 255})
   love.graphics.print(message, image:getWidth(), love.graphics.getHeight() - image:getHeight())
   love.graphics.setColor({255, 255, 255, 255})
end

function love.draw()
   love.graphics.draw(bg, 0, 0)
   love.graphics.draw(player, x, y)

   love.graphics.setColor({0, 0, 0, 255})
   info = bullet_count .. "/" .. 60 .. "\n" .. "Reloading: " .. is_reloading
   love.graphics.print(info, 0, 0)
   love.graphics.setColor({255, 255, 255, 255})

   bullet_now = 0

   while bullet_now <= 60 do
      if bullets[bullet_now] ~= nil and bullets[bullet_now].exists == 1 then
           love.graphics.draw(bullet, bullets[bullet_now].x, bullets[bullet_now].y)
      end
      bullet_now = bullet_now + 1
   end

   if say_msg[1] ~= nil then
      say(say_msg[1], say_msg[2])
   end
end

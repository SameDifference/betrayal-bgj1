function love.load()
   love.graphics.setCaption("BaconGameJam 1")
   bg = love.graphics.newImage("sky.jpg")
   player = love.graphics.newImage("player.png")
   bullet = love.graphics.newImage("bullet.png")
   jackson = love.graphics.newImage("jackson.png")
   hall = love.graphics.newImage("hall.png")
   mine = love.graphics.newImage("mine.png")
   le_programmer = love.graphics.newImage("helper.png")
   
   say_msg = {}
   conversation = 0
   x = 50
   y = love.graphics.getHeight() - player:getHeight()
   bullets = { {} }
   for i=1,60 do
       bullets[i] = {}
   end

   mines = { {nil} }
   current_mine = 1
   math.randomseed(os.time())

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
      [80] = {"Spacebar to shoot.\n    Arrows to move.\n     z to reload\n     This game is lovely, and so are you.", le_programmer},
      [90] = {nil, nil},
      [115] = {"Something is wrong... these are military ghosts!", jackson},
      [130] = {"Delta X skies are clear. Very well played on defeating the magic ball attack.", hall},
      [137] = {"But you, you must die!", hall},
      [145] = {"I knew it Hall! You'll never take me!", jackson}, --_alarm},
      [150] = {"It was not my order. But it must happen, die Jackson! Die!", hall},
      [158] = {nil, nil}
   }
   
   post = { 
      ["enemies killed"] = 0,
      ["enemies let go"] = 0,
      ["bullets fired"] = 0,
      ["times reloaded"] = 0,
      ["time taken"] = 0,
      ["game finished"] = 0
   }
end

function love.update(dt)
   if love.keyboard.isDown("right") then
      x = x + (speed * dt)
   elseif love.keyboard.isDown("left") then
      x = x - (speed * dt)
   end
   
   post["time taken"] = post["time taken"] + dt

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
         post["bullets fired"] = post["bullets fired"] + 1
         --print("fire")
         if bullet_count < 1 then
            is_reloading = 1
            post["times reloaded"] = post["times reloaded"] + 1
            --print("reloading")
         end
      end
   end

   if love.keyboard.isDown("z") then
      if is_reloading == 0 then
         is_reloading = 1
         --print("reloading")
         post["times reloaded"] = post["times reloaded"] + 1
      end
   end

   bullet_now = 1

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
   
   mine_now = 1
   
   while mine_now <= current_mine do
      if mines[mine_now] ~= nil and mines[mine_now].y ~= nil then
         mines[mine_now].y = mines[mine_now].y + (dt * 50)
         if mines[mine_now].y > love.graphics.getHeight() then
            mines[mine_now] = { nil }
            post["enemies let go"] = post["enemies let go"] + 1
         end
      end
      mine_now = mine_now + 1
   end
   
   if conversation > 80 and conversation < 130 then
      --print("mine considered")
      if math.random(1, 100) > 97 then
         --print("random passed")
         --print("done")
         mines[current_mine] = {}
         mines[current_mine].x = math.random(0, love.graphics.getHeight())
         mines[current_mine].y = 0
         mines[current_mine].exists = 1
         current_mine = current_mine + 1
      end
   end

   local collidersbull = 1
   local collidersmine = 1
   local ydiff = 0
   local xdiff = 0

   while collidersbull <= 60 do
      if bullets[collidersbull].y ~= nil and bullets[collidersbull].exists == 1 then
      while collidersmine <= current_mine do
         if mines[collidersmine] ~= nil and mines[collidersmine].y ~= nil then
         ydiff = bullets[collidersbull].y - mines[collidersmine].y
         if ydiff <= 60 and ydiff >= 0 then
            xdiff = bullets[collidersbull].x - mines[collidersmine].x
            if xdiff <= 60 and xdiff >= 0 then
               mines[collidersmine] = {nil}
               post["enemies killed"] = post["enemies killed"] + 1
            end
         end
         end
         collidersmine = collidersmine + 1
      end
      end
      collidersbull = collidersbull + 1
   end
   conversation = conversation + dt
   if love.keyboard.isDown("s") and conversation < 70 then
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

function drawall(tbl, untnum, image)
   local x = 1
   while x <= untnum do
      if tbl[x] ~= nil and tbl[x].exists == 1 then
         love.graphics.draw(image, tbl[x].x, tbl[x].y)
      end
      x = x + 1
   end
end

function love.draw()
   love.graphics.draw(bg, 0, 0)
   love.graphics.draw(player, x, y)

   love.graphics.setColor({0, 0, 0, 255})
   info = bullet_count .. "/" .. 60 .. "\n" .. "Reloading: " .. is_reloading
   love.graphics.print(info, 0, 0)
   love.graphics.setColor({255, 255, 255, 255})
   
   drawall(bullets, 60, bullet)
   drawall(mines, current_mine, mine)

   if say_msg[1] ~= nil then
      say(say_msg[1], say_msg[2])
   end
end

function love.quit()
   -- temporary post mortem stats
   print("Enemies Killed: " .. post["enemies killed"])
   print("Enemies Let Go: " .. post["enemies let go"])
   print("Bullets Fired: " .. post["bullets fired"])
   print("Times Reloaded: " .. post["times reloaded"])
   print("Time Taken: " .. post["time taken"])
   print("Completed? " .. ((post["game finished"] > 0) and "Yes!" or "No."))
end
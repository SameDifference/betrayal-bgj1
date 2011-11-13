function love.load()
   love.graphics.setCaption("BaconGameJam 1")
   bg = love.graphics.newImage("sky.jpg")
   player = love.graphics.newImage("player.png")
   bullet = love.graphics.newImage("bullet.png")
   jackson = love.graphics.newImage("jackson.png")
   hall = love.graphics.newImage("hall.png")
   mine = love.graphics.newImage("mine.png")
   le_programmer = love.graphics.newImage("helper.png")
   hallplane = love.graphics.newImage("hallplane.png")
   explosion = love.graphics.newImage("explosionun.png")
   
   hallfight = { }
   hallfight.x = love.graphics.getWidth() / 2
   hallfight.y = (hallplane:getHeight() == nil) and 0 or hallplane:getHeight()
   hallfight.health = 100
   
   playerfight = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() - player:getHeight(), health = 250, exists = 1}
   
   freezeplayer = 0
   drawnothing = 0
   
   say_msg = {}
   conversation = 0
   bullets = { {} }
   for i=1,60 do
       bullets[i] = {}
   end

   mines = { }
   current_mine = 1
   math.randomseed(os.time())

   bullet_count = 60
   is_reloading = 0
   speed = 100
   conv = {
      [1] = {"Delta X to Orange 3, do you copy?\n(Press s to skip dialogue.)", jackson},
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
      [115] = {"Something is wrong... these are our ghosts!", jackson},
      [130] = {"Delta X skies are clear. Very well played on defeating the enemy ghosts over.", hall},
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
   if freezeplayer == 0 then
   if love.keyboard.isDown("right") then
      playerfight.x = playerfight.x + (speed * dt)
   elseif love.keyboard.isDown("left") then
      playerfight.x = playerfight.x - (speed * dt)
   end
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
         bullets[bullet_count] = {}
         bullets[bullet_count].exists = 1
         bullets[bullet_count].x = playerfight.x + (player:getWidth() / 2)
         bullets[bullet_count].y = playerfight.y
         bullet_count = bullet_count - 1
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
            bullets[bullet_now] = { }
            --print("bullet leaves")
         end
      end
      bullet_now = bullet_now + 1
   end
   
   mine_now = 1
   
   while mine_now <= current_mine do
      if mines[mine_now] ~= nil and mines[mine_now].y ~= nil then
         if conversation < 150 then
            mines[mine_now].y = mines[mine_now].y + (dt * 50)
         else
            mines[mine_now].y = mines[mine_now].y + (dt * 300)
         end
         if mines[mine_now].y > love.graphics.getHeight() then
            mines[mine_now] = { nil }
            if conversation < 130 then
               post["enemies let go"] = post["enemies let go"] + 1
               playerfight.health = playerfight.health - 1
            end
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
         mines[current_mine].x = math.random(0, love.graphics.getWidth())
         mines[current_mine].y = 0
         mines[current_mine].exists = 1
         current_mine = current_mine + 1
      end
   elseif conversation > 150 then
      if math.random(1, 100) > 98 then
         --print("random passed")
         --print("done")
         mines[current_mine] = {}
         mines[current_mine].x = hallfight.x
         mines[current_mine].y = hallfight.y
         mines[current_mine].exists = 1
         current_mine = current_mine + 1
      end
   end
   if conversation < 150 then
      doescollide(bullets, mines, 60, current_mine, 60, 60, "kill")
   else
      doescollide(bullets, { hallfight }, 60, 1, 87, 68, "damage")
      hallfight.x = hallfight.x + (dt * ((hallfight.x - playerfight.x > 0) and -75 or 75))
   end
   
   doescollide(mines, { playerfight }, current_mine, 1, 87, 68, "damage")

   
   if hallfight.health < 1 then
      post["game finished"] = 1
      freezeplayer = 1
      hallfight.x = x
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

function doescollide(tbl1, tbl2, untnum1, untnum2, xsize, ysize, kill)
   coll1 = 1
   coll2 = 1
   if kill == "kill" then
      kill = 1
   else
      kill = 0
   end
   while coll1 <= untnum1 do
      if pcall(function () return tbl1[coll1].y end) == true and tbl1[coll1].exists == 1 then
      while coll2 <= untnum2 do
         if tbl2[coll2] ~= nil and pcall(function () return tbl2[coll2].y end) == true then
         ydiff = tbl1[coll1].y - ((tbl2[coll2].y == nil) and -5000 or tbl2[coll2].y)
         if ydiff <= ysize and ydiff >= 0 then
            xdiff = tbl1[coll1].x - ((tbl2[coll2].x == nil) and -5000 or tbl2[coll2].x)
            if xdiff <= xsize and xdiff >= 0 then
               if kill == 1 then
                  tbl1[coll1].exists = 0
                  tbl2[coll2].exists = 0
                  post["enemies killed"] = post["enemies killed"] + 1
               else
                  tbl1[coll1] = {}
                  tbl2[coll2].health = tbl2[coll2].health - 1
               end
            end
         end
         end
         coll2 = coll2 + 1
      end
      end
      coll1 = coll1 + 1
   end
end

function love.draw()
if drawnothing == 0 then
   love.graphics.draw(bg, 0, 0)
   love.graphics.draw(player, playerfight.x, playerfight.y)
   love.graphics.draw(player, playerfight.x, playerfight.y)

   love.graphics.setColor({0, 0, 0, 255})
   info = bullet_count .. "/" .. 60 .. "\n" .. "Reloading: " .. is_reloading .. "\n" .. "Your Health: " .. playerfight.health .. "\n" .. ((conversation > 150) and "Hall's Health: " .. hallfight.health or "")
   love.graphics.print(info, 0, 0)
   love.graphics.setColor({255, 255, 255, 255})
   
   drawall(bullets, 60, bullet)
   drawall(mines, current_mine, mine)

   if say_msg[1] ~= nil then
      say(say_msg[1], say_msg[2])
   end

   if conversation > 150 then
      love.graphics.draw(hallplane, hallfight.x, hallfight.y)
   end
else
   say("But I'm still alive.", jackson)
   love.graphics.fontSize(24)
   love.graphics.printf("But I'm still alive.", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
end
   
   if freezeplayer == 1 then
      hallfight.y = hallfight.y + 1
      say("We will both die, Jackson! I must fulfill the orders!", hall)
      if hallfight.y == (y - hallplane:getHeight()) then
         love.graphics.setBackgroundColor(255, 0, 0)
         love.graphics.draw(explosion, x, y)
         drawnothing = 1
         freezeplayer = 0
      end
   end

   if playerfight.health < 1 then
      love.graphics.setBackground(255, 0, 0)
      love.graphics.printf("You have died.", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
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
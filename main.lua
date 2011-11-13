function love.load()
   love.graphics.setCaption("Betrayal")
   bg = love.graphics.newImage("sky.jpg")
   player = love.graphics.newImage("player.png")
   bullet = love.graphics.newImage("bullet.png")
   jackson = love.graphics.newImage("jackson.png")
   hall = love.graphics.newImage("hall.png")
   mine = love.graphics.newImage("mine.png")
   le_programmer = love.graphics.newImage("helper.png")
   hallplane = love.graphics.newImage("hallplane.png")
   explosion = love.graphics.newImage("explosionun.png")
   
   bigfont = love.graphics.newFont(28)
   
   hallfight = { }
   hallfight.x = love.graphics.getWidth() / 2
   hallfight.y = (hallplane:getHeight() == nil) and 0 or hallplane:getHeight()
   hallfight.health = 100
   
   playerfight = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() - player:getHeight(), health = 200, exists = 1}
   

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
      [9] = {"Orange 3 copies loud and clear Delta X over.\nYour mission is simple Delta X disarm enemy ghost missles in the area. Over.", hall},
      [16] = {"Clear copy Orange 3, can you return the current time? Over.", jackson},
      [25] = {"Orange 3 to Delta X it's 11:11 11/11/11, do you copy?", hall},
      [32] = {"Delta X copies Orange 3, over.", jackson},
      [40] = {"*shuts down the radio*", jackson},
      [44] = {"I've spent so far away from home.", jackson},
      [52] = {"Something is amiss, Hall seems a little shifty.\n...\nHe probably had too much caffine again.", jackson},
      [61] = {"Delta X we have hostile movement in your area over!", hall},
      [70] = {"Copy that Orange 3, will take them out.", jackson},
      [80] = {"Spacebar to shoot.\n    Arrows to move.\n    z to reload\n    This game is lovely, and so are you.", le_programmer},
      [90] = {nil, nil},
      [115] = {"Something is wrong... these are our ghost missles!", jackson},
      [130] = {"Delta X skies are clear. Very well played on defeating the enemy ghosts over.", hall},
      [137] = {"But now, you must die!", hall},
      [145] = {"I knew something was wrong Hall. I won't be the one dying today!", jackson},
      [150] = {"It was not my order. But it must happen. Die Jackson! Die!", hall},
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
   if freezeplayer ~= 1 then
      if love.keyboard.isDown("right") then
         playerfight.x = playerfight.x + (speed * dt)
         if playerfight.x > love.graphics.getWidth() - 87 then
            playerfight.x = love.graphics.getWidth() - 87
         end
      elseif love.keyboard.isDown("left") then
         playerfight.x = playerfight.x - (speed * dt)
         if playerfight.x < 0 then
            playerfight.x = 0
         end
      end      
      post["time taken"] = post["time taken"] + dt
      

      if is_reloading > 0 then
          is_reloading = is_reloading - dt
          if is_reloading < 0 then
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
            if bullet_count < 1 then
               is_reloading = 1
               post["times reloaded"] = post["times reloaded"] + 1
            end
         end
      end

      if love.keyboard.isDown("z") then
         if is_reloading == 0 then
            is_reloading = 1
            post["times reloaded"] = post["times reloaded"] + 1
         end
      end
   end

   bullet_now = 1

   while bullet_now <= 60 do
      if bullets[bullet_now] ~= nil and bullets[bullet_now].exists == 1 then
         bullets[bullet_now].y = bullets[bullet_now].y - (dt * 300)
         if bullets[bullet_now].y < 0 then
            bullets[bullet_now] = { }
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
      if math.random(1, 100) > 97 then
         mines[current_mine] = {}
         mines[current_mine].x = math.random(60, love.graphics.getWidth() - 60)
         mines[current_mine].y = 0
         mines[current_mine].exists = 1
         current_mine = current_mine + 1
      end
   elseif conversation > 150 then
      if math.random(1, 100) > 90 then
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
      if freezeplayer ~= 1 then
         doescollide(bullets, { hallfight }, 60, 1, 87, 68, "damage")
      end
      if hallfight.health > 0 then
         hallfight.x = hallfight.x + (dt * ((hallfight.x - playerfight.x > 0) and -75 or 75))
      end
   end
   
   if freezeplayer ~= 1 then
      doescollide(mines, { playerfight }, current_mine, 1, 87, 68, "damage")
   end

   
   if hallfight.health < 1 then
      post["game finished"] = 1
      freezeplayer = 1
      hallfight.x = playerfight.x
      hallfight.health = 0
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
   love.graphics.printf("Congratulations!\n" ..
   "Enemies Killed: " .. post["enemies killed"] .. "\n" ..
   "Enemies Let Go: " .. post["enemies let go"] .. "\n" ..
   "Bullets Fired: " .. post["bullets fired"] .. "\n" ..
   "Times Reloaded: " .. post["times reloaded"] .. "\n" ..
   "Time Taken: " .. math.floor(post["time taken"]) .. "\n" ..
   "Completed? " .. ((post["game finished"] > 0) and "Yes!" or "No."), 
   0, love.graphics.getHeight() / 4, love.graphics.getWidth(), "center")
   if os.time() - untilalive > 5 and os.time() - untilalive < 15 then
      say("Nice try, but I'm still alive.", jackson)
   elseif os.time() - untilalive  > 18 then
      say("Made by: le_programmer for BaconGameJam #1\nAll art from OpenGameArt.org\nAll characters appearing in this work are fictitious.\nAny resemblance to real persons, living or dead, is purely coincidental.", le_programmer)
   end
end
   
   if freezeplayer == 1 and drawnothing == 0 then
      hallfight.y = hallfight.y + 5
      say("DIE!", hall)
      if math.random(1, 100) == 99 then
         love.graphics.draw(explosion, hallfight.x, hallfight.y)
      end
      if hallfight.y > playerfight.y then
         love.graphics.setBackgroundColor(128, 128, 128)
         love.graphics.draw(explosion, playerfight.x, playerfight.y)
         drawnothing = 1
         freezeplayer = 0
         untilalive = os.time()
      end
   end
   
   if playerfight.health < 1 then
      love.graphics.setBackgroundColor(255, 0, 0)
      love.graphics.printf("You have died.", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
      freezeplayer = 1
      drawnothing = 1
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
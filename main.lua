--Requiring the library
reptile = require "reptile"

love.window.setMode(200, 200)

function love.load()
	tsize = 40
	reptile.setSize(tsize)
	map = {
		{1, 1, 1, 1, 1},
		{1, 0, 0, 0, 1},
		{1, 0, 1, 1, 1},
		{1, 0, 0, 0, 1},
		{1, 1, 1, 1, 1}
	}
	
	player = {
		l = 60, t = 60,
		w = 20, h = 20,
		vx = 0, vy = 0
	}
end

function love.update(dt)
	local speed = 180 * dt
	player.vx, player.vy = 0, 0
	if love.keyboard.isDown("left") then
		player.vx = -speed
	elseif love.keyboard.isDown("right") then
		player.vx = speed
	elseif love.keyboard.isDown("up") then
		player.vy = -speed
	elseif love.keyboard.isDown("down") then
		player.vy = speed
	end
	
	--CORE FUNCTION OF THE LIBRARY HERE
	--You must pass a table with l and t (left and top), w and h (width and height), and
	--vx and vy (velocities for each axis).
	local cols = reptile.collide(player)
	player.l, player.t = cols.l, cols.t
end

--Here you must define a function that returns true if the given grid coordinate is a tile.
function reptile.checkGrid(x, y)
	local check = map[x + 1][y + 1]
	if check == 1 then
		return true
	end
end

function love.draw()
	love.graphics.translate(-40, -40)
	--Draw Map
	for y = 1, #map do
		for x = 1, #map[y] do
			if map[y][x] == 1 then
				love.graphics.setColor(255,255,255)
				love.graphics.rectangle("fill", x * tsize, y * tsize, tsize, tsize)
			end
		end
	end
	
	love.graphics.translate(40, 40)
	--Draw Player
	love.graphics.setColor(100,100,255)
	love.graphics.rectangle("line", player.l, player.t, player.w, player.h)
end
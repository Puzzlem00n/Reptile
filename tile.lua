local tile = {
	_LICENSE = [[
    MIT LICENSE

    Copyright (c) 2014 Timothy Bumpus

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

local micro = .001
local tileSize

--Returns positive 1 for positive numbers, -1 for negative numbers and 0 for 0.
local function sign(x)
	return x < 0 and -1 or (x > 0 and 1 or 0)
end

--Slightly faster version of math.min()
local function min(a,b) return a < b and a or b end

--Decides how to order the parameters passed to tile.checkPoint to supposedly reduce
--complications. If axis is true, the x axis is being checked, and y otherwise.
local function checkPointAxis(x, y, axis)
	if axis then ans = tile.checkPoint(x, y)
	else ans = tile.checkPoint(y, x) end
	return ans
end

--A shortcut to point checking that can check three coordinates at a time.
local function checkPoints(edge, t, axis)
	if checkPointAxis(t[1], edge, axis) or
	checkPointAxis(t[2], edge, axis) or
	checkPointAxis(t[3], edge, axis) then
	return true end
end

--Collides either axis with the tiles and returns the axis's
--post-collision coordinate, velocity and normal.
local function collideAxis(a,b,l1,l2,v,vs,axis)
	local check = true
	local n = 0
	
	v = v*vs
	local fmin, fplus = a + v, a + l1 + v
	check = true
	if vs == 1 then edge = fplus divi = fplus
	elseif vs == -1 then edge = fmin divi = a
	else check = false end
	if check and checkPoints(edge, {b, b+l2-micro, b+l2/2}, axis) then
		a = math.floor(divi / tileSize) * tileSize
		if vs == 1 then a = a - l1 end
		v = 0
		n = -vs
	end
	a = a + v
	return a, v, n
end

--Ensures that colliding objects cannot go through tiles if they are moving very fast.
local function collideNoTunnel(a,b,l1,l2,v,axis)
	local vsign, av, maxv
	maxv = tileSize-micro
	vsign = sign(v)
	av = math.abs(v)
	if av < tileSize then
		a, v, n = collideAxis(a,b,l1,l2,av,vsign,axis)
	else
		while av > 0 do
			local nowv = min(maxv, av)
			a, nowv, n = collideAxis(a,b,l1,l2,nowv,vsign,axis)
			if n ~= 0 then
				v = nowv
				break
			end
			av = av - maxv
		end
	end
	return a, v, n
end

--Public interface:

--Sets the size of each tile in the grid.
function tile.setSize(x) tileSize = x return tileSize end

--Gets the size of each tile in the grid.
function tile.getSize() return tileSize end

--Takes a table of rectangle coors, dimensions and velocities. Returns a
--table with post-collision coors, velocities and normals for each axis.
function tile.collide(rect)
	local x, y = rect.x, rect.y
	local nx, ny = 0
	local w, h = rect.w, rect.h
	local vx, vy = rect.vx, rect.vy
	
	x, vx, nx = collideNoTunnel(x,y,w,h,vx,false)
	
	y, vy, ny = collideNoTunnel(y,x,h,w,vy,true)
	
	return {x = x, y = y, vx = vx, vy = vy, nx = nx, ny = ny}
end

--Converts pixel coordinates to grid coordinates and passes them to checkGrid.
function tile.checkPoint(x, y)
	return tile.checkGrid(math.floor(y/tileSize), math.floor(x/tileSize))
end

--OVERRIDABLE. Returns true if the given point on the tile grid is solid,
--i.e. should be collided with.
function tile.checkGrid(x, y)
end

return tile
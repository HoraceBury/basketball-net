display.actualCenterX, display.actualCenterY = display.actualContentWidth*.5, display.actualContentHeight*.5

require("physics")
physics.start()
physics.setGravity(0,10)
physics.setDrawMode("hybrid")

local ballfilter = { categoryBits=1, maskBits=3 }
local basketfilter = { categoryBits=2, maskBits=1 }

local function newWall( p, x, y, w, h )
	local rect = display.newRect( p, x, y, w, h )
	physics.addBody( rect, "static", { bounce=1 } )
	return rect
end

newWall( display.currentStage, display.actualCenterX, -10, display.actualContentWidth, 40 )
--newWall( display.currentStage, display.actualCenterX, display.actualContentHeight+10, display.actualContentWidth, 40 )
newWall( display.currentStage, -10, display.actualCenterY, 40, display.actualContentHeight )
newWall( display.currentStage, display.actualContentWidth+10, display.actualCenterY, 40, display.actualContentHeight )

function addBall()
	local ball = display.newCircle( math.random(100, display.actualContentWidth-100), 50, 30 )
	physics.addBody( ball, "dynamic", { bounce=1, density=.5, radius=30, filter=ballfilter } )
	ball:setLinearVelocity( math.random(-10,10)*50, 0 )
end

timer.performWithDelay( 1000, addBall, 0 )
addBall()

local objectcount

local function removeOffScreenObjects()
	for i=display.currentStage.numChildren, 1, -1 do
		local item = display.currentStage[i]
		if (item.y > display.actualContentHeight+250) then
			display.remove( item )
		end
	end
	
	if (objectcount == nil) then
		objectcount = display.newText{ x=0, y=0, text="", fontSize=60 }
	end
	
	objectcount.text = display.currentStage.numChildren
	objectcount.x, objectcount.y = objectcount.width*1, objectcount.height*1
end

timer.performWithDelay( 1000, removeOffScreenObjects, 0 )

local function newBasket( p, x, y, w, h )
	local group = display.newGroup()
	p:insert( group )
	
	local topleft = { x=x-w*.5, y=y-h*.5 }
	local topright = { x=x+w*.5, y=y-h*.5 }
	
	local bottomleft = { x=x-w*.35, y=y+h*.5 }
	local bottomright = { x=x+w*.35, y=y+h*.5 }
	
	local xGap, yGap = (topright.x-topleft.x)/4, (bottomleft.y-topleft.y)/4
	local xInc = (bottomleft.x-topleft.x)/4
	
	for r=topleft.y, bottomleft.y, yGap do
		for c=topleft.x, topright.x+1, xGap do
			local dot = display.newCircle( group, c, r, 1 )
			physics.addBody( dot, "dynamic", { radius=1, density=.5, isSensor=true, filter=basketfilter } )
			if (r==topleft.y) then dot.bodyType = "static" end
			if (c==topleft.x or c>=topright.x) then dot.isSensor=false end
		end
		topleft.x, topright.x = topleft.x+xInc, topright.x-xInc
		xGap = (topright.x-topleft.x)/4
	end
	
	for r=2, 6 do
		for c=1, 5 do
			local a, b
			if (c>1) then
				a, b = group[(r-2)*5+(c-1)], group[(r-2)*5+c]
				local j = physics.newJoint( "distance", a, b, a.x, a.y, b.x, b.y )
				print(j.frequency)
				j.dampingRatio = 0
				j.frequency = 5
			end
			if (r<6) then
				a, b = group[(r-2)*5+c], group[(r-1)*5+c]
				local j = physics.newJoint( "distance", a, b, a.x, a.y, b.x, b.y )
				print(j.frequency)
--				j.frequency = 1
			end
		end
	end
end
newBasket( display.currentStage, display.actualContentWidth*.3, display.actualCenterY, 150, 100 )
newBasket( display.currentStage, display.actualContentWidth*.6, display.actualCenterY, 150, 100 )

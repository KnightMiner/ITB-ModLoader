
UiScrollArea = Class.inherit(Ui)

function UiScrollArea:new()
	Ui.new(self)

	self.scrollrect = sdl.rect(0,0,0,0)
	self.scrollbuttonrect = sdl.rect(0,0,0,0)

	self.scrollwidth = 16
	self.buttonheight = 0
	
	self.padr = self.padr + self.scrollwidth
	self.nofity = true

	self.scrollPressed = false
	self.scrollHovered = false
	self.clipRect = sdl.rect(0,0,0,0)
end

function UiScrollArea:draw(screen)
	local clipRect = self.clipRect
	
	local currentClipRect = screen:getClipRect()
	if currentClipRect then
		clipRect = self.clipRect:getIntersect(currentClipRect)
	end
	
	screen:clip(clipRect)
	Ui.draw(self, screen)
	
	if self.innerHeight > self.h then
		screen:drawrect(deco.colors.black, self.scrollrect)
		drawborder(screen, deco.colors.white, self.scrollrect, 2)

		if self.scrollPressed then
			screen:drawrect(deco.colors.focus, self.scrollbuttonrect)
		elseif self.scrollHovered then
			screen:drawrect(deco.colors.buttonborderhl, self.scrollbuttonrect)
		else
			screen:drawrect(deco.colors.white, self.scrollbuttonrect)
		end
	end
	
	screen:unclip()
end

function UiScrollArea:relayout()
	Ui.relayout(self)
	
	self.scrollrect.x = self.screenx + self.w - self.scrollwidth
	self.scrollrect.y = self.screeny
	self.scrollrect.w = self.scrollwidth
	self.scrollrect.h = self.h

	if self.innerHeight > self.h and self.dy + self.h > self.innerHeight then
		self.dy = self.innerHeight - self.h
	elseif self.innerHeight < self.h and self.dy > 0 then
		self.dy = 0
	end
	
	local ratio = self.h / self.innerHeight
	local offset = self.dy / (self.innerHeight - self.h)
	if ratio > 1 then ratio = 1 end
	
	self.buttonheight = ratio * self.h
	self.scrollbuttonrect.x = self.screenx + self.w - self.scrollwidth
	self.scrollbuttonrect.y = self.screeny + offset * (self.h - self.buttonheight)
	self.scrollbuttonrect.w = self.scrollwidth
	self.scrollbuttonrect.h = self.buttonheight

	self.clipRect.x = self.screenx
	self.clipRect.y = self.screeny
	self.clipRect.w = self.w
	self.clipRect.h = self.h
end

function UiScrollArea:mousedown(x, y, button)
	if x >= self.scrollrect.x then
		if self.root.pressedchild ~= nil then
			self.root.pressedchild.pressed = false
		end

		self.root.pressedchild = self
		self.pressed = true

		if self.innerHeight > self.h then
			local ratio = (y - self.screeny - self.buttonheight/2) / (self.h - self.buttonheight)
			if ratio < 0 then ratio = 0 end
			if ratio > 1 then ratio = 1 end

			self.dy = ratio * (self.innerHeight - self.h)

			self.scrollPressed = true
			return true
		end
	end

	return Ui.mousedown(self, x, y, button)
end

function UiScrollArea:mouseup(x, y, button)
	self.scrollPressed = false

	return Ui.mouseup(self, x, y, button)
end

function UiScrollArea:wheel(mx, my, y)
	self:relayout()

	-- Have the scrolling speed scale with the height of the inner area,
	-- but capped by the height of the viewport.
	local d = math.max(20, self.innerHeight * 0.1)
	d = math.min(d, self.h * 0.8)
	d = d * y

	local startdy = self.dy

	self.dy = self.dy - d
	if self.dy < 0 then self.dy = 0 end
	if self.dy + self.h > self.innerHeight then self.dy = self.innerHeight - self.h end
	if self.h > self.innerHeight then self.dy = 0 end

	-- Call back to mousemove to update hover and tooltip statuses of the area's
	-- child elements.
	Ui.mousemove(self, mx, my + (self.dy - startdy))

	return Ui.wheel(self, mx, my, y)
end

function UiScrollArea:mousemove(x, y)
	self.scrollHovered = x >= self.scrollrect.x

	if self.scrollPressed then
		self:relayout()

		local ratio = (y - self.screeny - self.buttonheight/2) / (self.h-self.buttonheight)
		if ratio < 0 then ratio = 0 end
		if ratio > 1 then ratio = 1 end
		
		self.dy = ratio * (self.innerHeight - self.h)

		return true
	end

	return Ui.mousemove(self, x, y)
end

function UiScrollArea:onMouseExit()
	self.scrollHovered = false
end

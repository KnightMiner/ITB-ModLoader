--[[
	Adds a "Mod Content" button to the main menu, as well as
	an API for adding items to the menu it opens.
--]]

local modContent = {}
function sdlext.addModContent(text, func, tip)
	local obj = {caption = text, func = func, tip = tip}
	
	modContent[#modContent+1] = obj
	
	return obj
end

local buttonModContent
sdlext.addUiRootCreatedHook(function(screen, uiRoot)
	if buttonModContent then return end
	
	buttonModContent = MainMenuButton("short")
		:pospx(0, screen:h() - 186 * GetUiScale())
		:caption("Mod Content")
		:addTo(uiRoot)
	buttonModContent.visible = false

	sdlext.addGameWindowResizedHook(function(screen, oldSize)
		buttonModContent:pospx(0, screen:h() - 186 * GetUiScale())
	end)

	sdlext.addSettingsStretchChangedHook(function(screen, settingsStretched, uiScale)
		buttonModContent:pospx(0, screen:h() - 186 * GetUiScale())
	end)

	buttonModContent.onclicked = function(self, button)
		if button == 1 then
			sdlext.showDialog(function(ui, quit)
				ui.onclicked = function(self, button)
					quit()
					return true
				end

				local uiScale = GetUiScale()

				local frame = Ui()
					:width(0.4):height(0.8)
					:posCentered()
					:caption("Mod Content")
					:decorate({ DecoFrameHeader(), DecoFrame() })
					:addTo(ui)

				local scrollarea = UiScrollArea()
					:width(1):height(1)
					:padding(16 * uiScale)
					:addTo(frame)

				local holder = UiBoxLayout()
					:vgap(12 * uiScale)
					:width(1)
					:addTo(scrollarea)
				
				local font = sdlext.font("fonts/NunitoSans_Regular.ttf", 12 * uiScale)
				local buttonHeight = 42 * uiScale
				for i = 1,#modContent do
					local obj = modContent[i]
					local entryBtn = Ui()
						:width(1)
						:heightpx(buttonHeight)
						:caption(obj.caption)
						:settooltip(obj.tip)
						:decorate({ DecoButton(), DecoAlign(0, -1 * uiScale), DecoCaption(font) })
						:addTo(holder)

					if obj.disabled then entryBtn.disabled = true end
					
					entryBtn.onclicked = function(self, button)
						if button == 1 then
							obj.func()

							return true
						end

						return false
					end
				end
			end)

			return true
		end

		return false
	end
end)

sdlext.addMainMenuEnteredHook(function(screen, wasHangar, wasGame)
	if not buttonModContent.visible or wasGame then
		buttonModContent.visible = true
		buttonModContent.animations.slideIn:start()
	end
end)

sdlext.addMainMenuExitedHook(function(screen)
	buttonModContent.visible = false
end)

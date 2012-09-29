-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "widget" library
local widget = require "widget"
local TwitterManager = require "utils.Twitter"
--------------------------------------------


-- forward declarations and other locals
local tBtn_tweet, tBtn_friend, tBtn_media
local tLbl_tweet, tLbl_friend, tLbl_media
local mainBG, screenshot


local function onMediaBtnRelease()
	--Take the screenshot
	local baseDir = system.DocumentsDirectory
	screenshot = "ss_"..os.date("%Y%m%d%H%M%S") .. ".jpg"
	display.save(scene.view, screenshot, baseDir)

	local options =
		{
    		isModal = true,
    		params = 
    		{
    			type = "twitter",
    			action = "media",
    			img = screenshot
    		}
    		
		}
	storyboard.showOverlay("social_overlay", options)	
	return true
end

local function onFriendBtnRelease()
	local options =
		{
    		isModal = true,
    		params = 
    		{
    			type = "twitter",
    			action = "friend"
    		}
    		
		}
	storyboard.showOverlay("social_overlay", options)	
	return true
end

local function onTweetBtnRelease()
	local options =
		{
    		isModal = true,
    		effect = "slideDown",
    		time = 300,
    		params = 
    		{
    			type = "twitter",
    			action = "tweet"
    		}
    		
		}
	storyboard.showOverlay("social_overlay", options)	
	return true
end



-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	mainBG = display.newImageRect( "images/main_BG.png", 480, 360 )
	mainBG:setReferencePoint(display.BottomCenterReferencePoint)
	mainBG.x, mainBG.y = halfW, screenH

	-- create a widget button (which will initiate the social overlay)
	tBtn_media = widget.newButton{
		default="images/button_screenshot.png", 
		over = "images/button_screenshot.png",
		width=93, height=93,
		left = 356, top = 200,
		onRelease = onMediaBtnRelease	
	}
	
	tBtn_friend = widget.newButton{
		default="images/button_follow.png", 
		over = "images/button_follow.png",
		width=93, height=93,
		left = 160, top = 205,
		onRelease = onFriendBtnRelease	
	}
	
	tBtn_tweet = widget.newButton{
		default="images/button_twitter.png", 
		over = "images/button_twitter.png",
		width=93, height=93,
		left = 260, top = 200,
		onRelease = onTweetBtnRelease	
	}
	
	-- all display objects must be inserted into group
	group:insert( mainBG )
	group:insert( tBtn_tweet )
	group:insert( tBtn_friend )
	group:insert( tBtn_media )
	mainBG:toBack()
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	if mainBG then
		mainBG:removeSelf()	-- widgets must be manually removed
		mainBG = nil
	end
	if tBtn_media then
		tBtn_media:removeSelf()	-- widgets must be manually removed
		tBtn_media = nil
	end	
	if tBtn_tweet then
		tBtn_tweet:removeSelf()	-- widgets must be manually removed
		tBtn_tweet = nil
	end	
	if tBtn_friend then
		tBtn_friend:removeSelf()	-- widgets must be manually removed
		tBtn_friend = nil
	end	
	
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene
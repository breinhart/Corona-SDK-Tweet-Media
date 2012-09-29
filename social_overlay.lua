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
local sceneBG, textField, okBtn, cancelBtn, textCount, imgIcon, bgMask, textFriend
local params
local callback = {}

-- Callbacks
function callback.twitterCancel()
	print( "Twitter Cancel" )
	native.setActivityIndicator( false )
	--statusMessage.textObject.text = "Twitter Cancel"
	storyboard.hideOverlay()
end

function callback.twitterSuccess()
	print( "Twitter Success" )
	native.setActivityIndicator( false )
	native.showAlert("Success", "We have completed your twitter request!", { "OK" } )
	params.success = true
	storyboard.hideOverlay()
end

function callback.twitterFailed()
	native.setActivityIndicator( false )
	print( "Failed: Invalid Token" )
	native.showAlert("Fail!", "An error occured while accessing Twitter.  Please check your internet connection and try again.", { "OK" } )
	storyboard.hideOverlay()
end

local function tweet_media( img, msg )
	--local value = "Recent photo taken while playing Political Arena for iOS! #PoliticalArena @vellumgames"
	native.setActivityIndicator( true )
	timer.performWithDelay(400, function() TwitterManager.tweet_media(callback, msg, img) end )
end
local function tweet(msg)
	native.setActivityIndicator( true )
	timer.performWithDelay(400, function() TwitterManager.tweet(callback, msg, img) end )
end
local function friend()
	native.setActivityIndicator( true )
	timer.performWithDelay(400, function() TwitterManager.create_friendship(callback, "vellumgames") end )
end
-- 'onRelease' event listener for playBtn
local function onOkBtnRelease()
	
	if params.type == "twitter" then
		if params.action == "tweet" then
			tweet(textField.text)
		elseif params.action == "media" then
			tweet_media(params.img, textField.text)
		elseif params.action == "friend" then
			friend()
		end		
	else 
		--facebook.login( fbAppID, fbListener, { "publish_stream" } )
	end
	
	
	return true
end

local function onCancelBtnRelease()
	
	storyboard.hideOverlay()
end

local function onFocus( event )

	if event.phase == "submitted" or event.phase == "ended" then
		native.setKeyboardFocus( nil )
	elseif event.phase == "editing" then
		local sLen = string.len(event.text)
		
		if params.type == "twitter" then
			if sLen > 100 then
				textField.text = string.sub(event.text, 1, 100)
				textCount:setTextColor( 240, 35, 35 )
			else
				textCount:setTextColor( 245, 245, 230 )
			end
			textCount.text = sLen .. " / 100"
		end
		
	end
	
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
	params = event.params
	
	local asset_file = require("images.social_menu@"..scale.."x")
	local asset_data = { spriteSheetFrames = asset_file.getSpriteSheetData().frames }
	local asset_sheet = graphics.newImageSheet( "images/social_menu@"..scale.."x.png", asset_data )
	
	sceneBG = display.newImageRect( asset_sheet, 6, 236, 117 )
	sceneBG:setReferencePoint(display.TopCenterReferencePoint)
	sceneBG.x, sceneBG.y = halfW, 12
	
	bgMask = display.newRect(offsetX, offsetY, screenW, screenH)
	bgMask:setReferencePoint( display.BottomLeftReferencePoint)
	bgMask:setFillColor( 20, 72, 130 )
	bgMask.alpha = .7
	bgMask.x, bgMask.y = 0, screenH
	
	textCount = display.newText( "0 / 100", halfW-50, 109, "HelveticaNeue-CondensedBlack", 10)
	textCount:setTextColor( 60, 50, 60 )
		
	textField = native.newTextField( halfW-105, 40, 200, 60 )
	textField.font = native.newFont("HelveticaNeue-CondensedBlack", 13)
	
	textFriend = display.newText( "Follow @VellumGames?", halfW-70, 60, "HelveticaNeue-CondensedBlack", 15)
	textFriend:setTextColor( 40, 40, 40 )
	
	
	textField:addEventListener( "userInput", onFocus )
	
	if params.type == "twitter" then
		imgIcon = display.newImageRect( asset_sheet, 7, 59, 59 )
	else
		imgIcon = display.newImageRect( asset_sheet, 3, 64, 64)
	end
	imgIcon:setReferencePoint( display.TopLeftReferencePoint )
	imgIcon.x, imgIcon.y = halfW - 155, 0
	
	okBtn = widget.newButton{
		sheet = asset_sheet,
		defaultIndex=4, overIndex = 5,
		labelColor = { default={ 128, 255, 96, 255 }, over={ 0 } },
		width=64, height=64,
		left = halfW + 52, top = 100,
		onRelease = onOkBtnRelease
	}
	
	cancelBtn = widget.newButton{
		sheet = asset_sheet,
		defaultIndex=1, overIndex = 2,
		labelColor = { default={ 128, 255, 96, 255 }, over={ 0 } },
		width=64, height=60,
		left = halfW -15, top = 100,
		onRelease = onCancelBtnRelease
	}
		-- all display objects must be inserted into group
	group:insert( bgMask )
	group:insert( sceneBG )
	group:insert( imgIcon )
	group:insert( okBtn )
	group:insert( cancelBtn )
	group:insert( textCount ) 
	group:insert( textField )
	group:insert( textFriend )
	--:toBack()
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	if params.type == "twitter" then
		if params.action == "media" then
			textField.text = "Recent photo taken while playing Political Arena for iOS! @vellumgames #Political_Arena"
			textCount.text = string.len(textField.text) .. " / 100"
			textFriend.isVisible = false
		elseif params.action == "tweet" then
			textField.text = "I am really looking forward to playing Political Arena for iOS! @vellumgames #Political_Arena"
			textCount.text = string.len(textField.text) .. " / 100"
			textFriend.isVisible = false
		elseif params.action == "friend" then
			textFriend.isVisible = true
			textCount.isVisible = false
			textField.isVisible = false
		end
	else
		textCount.isVisible = false
		textField.text = "Recent photo taken while playing Political Arena for iOS!!"
	end	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	if sceneBG then
		sceneBG:removeSelf()	-- widgets must be manually removed
		sceneBG = nil
	end
	
	if okBtn then
		okBtn:removeSelf()	-- widgets must be manually removed
		okBtn = nil
	end
	
	if cancelBtn then
		cancelBtn:removeSelf()
		cancelBtn = nil
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
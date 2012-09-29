-------------------------------------------------------------------------------------------------------------------------
-- 
-- Twedia (Tweet Media) (I am funny)
--
-- Provided for free use in any form by Vellum Interactive, Inc
-- oAuth.lua and Twitter.lua are provided by Corona Labs under the MIT license.  
-- oAuth.lua and Twitter.lua have been modified by Vellum Interactive, Inc and are bound by the same MIT License.
--
-- If you found this code helpful, consider contributing to Vellum Interactive by purchasing one of our many fun games!
-- DreamCat is available for iOS
-- Political Arena is available for iOS and Android on September 27th, 2012
--
-------------------------------------------------------------------------------------------------------------------------


display.setStatusBar( display.HiddenStatusBar )

local storyboard = require "storyboard"

require "sqlite3"
settings = require("settings")

-- Set some global variables
halfW = display.contentWidth * .5
halfH = display.contentHeight * .5
offsetX = display.screenOriginX
offsetY = display.screenOriginY
screenH = display.contentHeight - offsetY*2
screenW = display.contentWidth - offsetX*2

-- Determine if we are in @1x or @2x scale.
if display.contentScaleX <= .5 then
	scale = 2
else
	scale = 1
end

-- MAIN -- 
local function main()
	
	-- set the seed for math.random , this ensures that it IS actually random
	math.randomseed(os.time())
	math.random()
	math.random()
	
	settings:init()
	--Do we already have a stored access_token?
	print (settings.game.twitter.access_token)
	
	storyboard.gotoScene( "menu" )

end
--kick it off
main()

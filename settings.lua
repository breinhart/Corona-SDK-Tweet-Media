module(..., package.seeall)

local json = require "json"
local db = {}
game = {}

function settings:init()
	local g = nil
	local path = system.pathForFile( "settings.sqlite", system.DocumentsDirectory )
	file = io.open( path, "r" )
	if( file == nil )then
		pathSource     = system.pathForFile( "db/settings.sqlite", system.ResourceDirectory )
		fileSource     = io.open( pathSource, "r" )
		contentsSource = fileSource:read( "*a" )
		pathDest = system.pathForFile( "settings.sqlite", system.DocumentsDirectory )
		fileDest = io.open( pathDest, "w" )
		fileDest:write( contentsSource )
		io.close( fileSource )
		io.close( fileDest )
	else
		io.close( file )
	end

	path = system.pathForFile( "settings.sqlite", system.DocumentsDirectory )
    db = sqlite3.open(path)

	local sql = 'CREATE TABLE IF NOT EXISTS settings (id INTEGER PRIMARY KEY, key UNIQUE, value);'
	db:exec(sql)
	game = get()
	
	if not game then
		game = require("default_settings")
	end

	save()
end

function settings:reset_game()
	local g=require("default_settings")
	game = copy(g.game)
	save()
end

function settings:close()
       db:close()
end

function settings:get()
	local val = nil
	for result in db:nrows('SELECT value FROM settings WHERE key="game"') do
		val =  json.decode(result.value)
		val = val[1]
	end
	return val
end

function settings:save()
	local sql = 'INSERT OR REPLACE INTO settings(key, value) VALUES ("game", \''..json.encode({game})..'\')'
	db:exec(sql)
	print("Settings Saved")
end

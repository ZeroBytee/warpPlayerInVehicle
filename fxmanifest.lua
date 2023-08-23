fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'GalaxicDev aka John Atlas>'
description 'just simple repair script for AstroRP'
version '1.0.0'

-- What to run
client_scripts {
    'client/*.lua'
}

-- What to run server side
--server_scripts {
--    'server/server.lua'
--}

dependencies { 'mysql-async', 'ox_lib', 'wasabi_bridge' }
shared_scripts { '@ox_lib/init.lua', '@wasabi_bridge/import.lua', 'configuration/*.lua' }

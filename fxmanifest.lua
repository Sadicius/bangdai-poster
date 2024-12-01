fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

shared_scripts { '@ox_lib/init.lua', 'shared/functions.lua' }

client_script { 'client/main.lua' }

server_script { '@oxmysql/lib/MySQL.lua', 'bridge/init.lua', 'server/main.lua' }

ui_page 'web/index.html'

files { 'web/**', 'bridge/**/*.lua', 'shared/config.lua', 'locales/*.json' }

lua54 'yes'

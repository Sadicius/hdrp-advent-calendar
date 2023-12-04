fx_version "cerulean"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

version "1.1.0"

shared_script {
    '@ox_lib/init.lua',
    "config.lua",
}

client_scripts {
    "client/client.lua",
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "server/server.lua",
}

dependencies {
    'rsg-core',
    'ox_lib',
}

lua54 "yes"
fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Phil'
description 'Cattle Drive Script for RSG-Core'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@rsg-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@rsg-core/server/main.lua',
    'server.lua'
}

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js'
}

ui_page 'ui/index.html'

dependencies {
    'rsg-core'
}

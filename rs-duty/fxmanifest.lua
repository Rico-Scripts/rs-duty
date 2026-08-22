fx_version 'cerulean'
game 'gta5'

author 'Rico Scripts'
description 'RS Duty - ESX Legacy duty system'
version '1.0.1'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@rs_discordlogs/server/intercept.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'rs_discordlogs'
}

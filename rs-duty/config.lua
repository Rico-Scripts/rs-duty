Config = {}

Config.Debug = false

-- Discord webhook, leeg laten om uit te schakelen.
Config.Webhook = ''
Config.WebhookName = 'RS Duty'

-- Zet true als een speler standaard uit dienst moet zijn na join/restart.
Config.DefaultOffDuty = true

-- Reset duty als de ESX job verandert.
Config.ResetOnJobChange = true

-- Alleen deze jobs toestaan. Leeg = alle jobs.
Config.AllowedJobs = {
    -- ['rsmechanic'] = true,
    -- ['police'] = true,
    -- ['ambulance'] = true,
}

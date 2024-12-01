local function hasFramework(framework)
    return GetResourceState(framework) ~= 'missing'
end

local framework = hasFramework('rsg-core') and 'rsg' or hasFramework('vorp_core') and 'vorp' or nil

if not framework then
	return print('No framework detected')
end

local resource = ('bridge.%s.server'):format(framework)

require (resource)

lib.print.info(('^1%s Framework Detected^0'):format(string.upper(framework)))
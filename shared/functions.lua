if IsDuplicityVersion() then
    function Notify(source, title, msg, type, dur)
        TriggerClientEvent('ox_lib:notify', source, {
            title = title,
            description = msg,
            type = type or 'inform',
            duration = dur or 5000
        })
    end
else
    function Notify(title, msg, type, dur)
        lib.notify({
            title = title,
            description = msg,
            type = type or 'inform',
            duration = dur or 5000
        })
    end
end
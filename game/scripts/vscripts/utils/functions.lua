function CDOTA_BaseNPC:RemoveAllAbilities()
    for i=0,32 do
        local ability = self:GetAbilityByIndex(i)
        if ability then
            self:RemoveAbility(ability:GetAbilityName())
        end
    end
end

function CDOTA_BaseNPC:AddAbilityCustom(ability_name)
    local ability = self:AddAbility(ability_name)
    if ability then
        ability:SetLevel(1)
        ability:SetHidden(true)
    end
end

function AddNewModifierForAllHeroes(modifier_name, duration)
    for id, info in pairs(player_system.PLAYERS) do
        if info.hero ~= nil then
            info.hero:AddNewModifier(info.hero, nil, modifier_name, {duration = duration})
        end
    end
end

function AddNewAbilityForAllHeroes(table)
    for id, info in pairs(player_system.PLAYERS) do
        if info.hero ~= nil then
            for _, ability_name in pairs(table) do
                info.hero:AddAbilityCustom(ability_name)
            end
        end
    end
end

function HiddenAbilities(table)
    for id, info in pairs(player_system.PLAYERS) do
        if info.hero ~= nil then
            for _, ability_name in pairs(table) do
                local ab = info.hero:FindAbilityByName(ability_name)
                if ab then
                    ab:SetHidden(true)
                end
            end
        end
    end
end

function SetCameraAll(target)
    for id, info in pairs(player_system.PLAYERS) do
        if info.hero ~= nil then
            PlayerResource:SetCameraTarget(id, target)
        end
    end 
end

function UnlockCameraAll()
    for id, info in pairs(player_system.PLAYERS) do
        if info.hero ~= nil then
            PlayerResource:SetCameraTarget(id, nil)
        end
    end 
end

function CDOTA_BaseNPC:SetCamera(target)
    PlayerResource:SetCameraTarget(self:GetPlayerOwnerID(), target) 
end

function CDOTA_BaseNPC:UnlockCamera()
	PlayerResource:SetCameraTarget(self:GetPlayerOwnerID(), nil)
end

function StartTimerLoading()  
    local timer = SpawnEntityFromTableSynchronous("info_target", { targetname = "hero_selection_timer" })
    timer:SetThink( _TimerThinker, 1 )
end

local _TimerThinker__Timers = {}
local _TimerThinker__Events = {}
local _TimerThinker__Events_Index = {}
local timer_dt = 1/30
local timer_time = 0
function _TimerThinker()
    local i = 1
    while _TimerThinker__Events_Index[i] and _TimerThinker__Events_Index[i] <= timer_time do
        local event_time = _TimerThinker__Events_Index[i]
        local tRemove_timers = {}
        
        for _, timer_id in pairs( _TimerThinker__Events[ event_time ] ) do
            local next_event_time = event_time
            if next_event_time and next_event_time <= timer_time then
                local interval = (_TimerThinker__Timers[ timer_id ])()
                if type(interval) ~= 'number' or interval < 0 then
                    next_event_time = nil
                else
                    next_event_time = next_event_time + interval
                end
            end
            
            if next_event_time then
                _AddTimerEvent( next_event_time, timer_id )
            else
                tRemove_timers[ timer_id ] = true
            end
        end
        
        for timer_id in pairs( tRemove_timers ) do
            _RemoveTimer( timer_id )
        end
        
        _RemoveTimerEvent( i )      
        i = i + 1
    end
    
    timer_time = timer_time + timer_dt
    return timer_dt
end

function _AddTimerEvent( event_time, timer_id )
    local i = 1
    while _TimerThinker__Events_Index[i] and _TimerThinker__Events_Index[i] < event_time do
        i = i + 1
    end
    
    if event_time == _TimerThinker__Events_Index[i] then
        local event = _TimerThinker__Events[ event_time ]
        table.insert( event, timer_id )
    else
        _TimerThinker__Events[ event_time ] = {timer_id}
        table.insert( _TimerThinker__Events_Index, i, event_time )
    end
    
    return i
end

function _RemoveTimerEvent( event_id )
    local event_time = _TimerThinker__Events_Index[ event_id ]
    table.remove( _TimerThinker__Events_Index, event_id )
    _TimerThinker__Events[ event_time ] = nil
end

function _AddTimer( f )
    local timer_id = 1
    while _TimerThinker__Timers[ timer_id ] do
        timer_id = timer_id + 1
    end
    _TimerThinker__Timers[ timer_id ] = f
    return timer_id
end

function _RemoveTimer( id )
    for _, event in pairs( _TimerThinker__Events ) do
        for k, timer_id in pairs( event ) do
            if timer_id == id then
                table.remove( event, k )
            end
        end
    end
    _TimerThinker__Timers[ id ] = nil
end

function Schedule( d, f )
    d = d or 0
    if type(d) ~= 'number' or d < 0 then
    end

    while d and d == 0 do
        d = f()
    end
    
    local next_trigger_time = timer_time
    if d and d > 0 then
        next_trigger_time = next_trigger_time + d
    else
        next_trigger_time = nil
    end
    
    if next_trigger_time then
        local timer_id = _AddTimer(f)
        _AddTimerEvent( next_trigger_time, timer_id )
        return timer_id
    end
end

function Timer( f, d )
    local lasttime = GameRules:GetGameTime()
    local oldcall_time = lasttime
    local interval = d
    return Schedule( d, function()
        local curtime = GameRules:GetGameTime()
        local dt = curtime - lasttime
        lasttime = curtime
        interval = ( interval or 0 ) - dt
        if interval < 1/32 then
            local new_interval = f( curtime - oldcall_time )
            oldcall_time = curtime
            if type(new_interval) == 'number' then
                interval = math.max( 0.01, interval + new_interval )
                return interval
            else
                return
            end
        end
        return math.max( interval, 0.01 )
    end )
end
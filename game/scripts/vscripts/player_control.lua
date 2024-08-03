if PlayersControlls == nil then
    PlayersControlls = class({})
    _G.PlayersControlls = PlayersControlls
end

function PlayersControlls:Init()
    CustomGameEventManager:RegisterListener("RL_MOUSE_POSITION", Dynamic_Wrap(PlayersControlls, "GetMousePosition"))
    CustomGameEventManager:RegisterListener("RL_BUTTON_PRESSED", Dynamic_Wrap(PlayersControlls, "ButtonPressed"))
    CustomGameEventManager:RegisterListener("RL_BUTTON_UNPRESSED", Dynamic_Wrap(PlayersControlls, "ButtonUnPressed"))
end

function PlayersControlls:GetMousePosition(data)
    local nPid = data.PlayerID
    local vPos = data.vPos
    if nPid ~= nil then
        local player = PlayerResource:GetPlayer(tonumber(nPid))
        if player then
            local hero = player:GetAssignedHero()
            if hero then
                hero.toDirect = vPos
            end
        end
    end
end

function PlayersControlls:ButtonPressed(data)
    local nPid = data.PlayerID
    local button = data.button
    if nPid ~= nil then
        local player = PlayerResource:GetPlayer(tonumber(nPid))
        if player then
            local hero = player:GetAssignedHero()
            if hero then
                if button == "W" then
                    hero.up = true
                elseif button == "A" then
                    hero.left = true
                elseif button == "S" then
                    hero.down = true
                elseif button == "D" then
                    hero.right = true
                elseif button == "MOUSE" then
                    hero.toDirect = data.Position
                    hero.shoot = true
                elseif button == "E" then
                    ItemsSystem:PickupDroppedItem(hero)
                end
            end
        end
    end
end

function PlayersControlls:ButtonUnPressed(data)
    local nPid = data.PlayerID
    local button = data.button
    if nPid ~= nil then
        local player = PlayerResource:GetPlayer(tonumber(nPid))
        if player then
            local hero = player:GetAssignedHero()
            if hero then
                if button == "W" then
                    hero.up = false
                elseif button == "A" then
                    hero.left = false
                elseif button == "S" then
                    hero.down = false
                elseif button == "D" then
                    hero.right = false
                elseif button == "MOUSE" then
                    hero.shoot_pos = nil
                    hero.shoot = false
                end
            end
        end
    end
end

function PlayersControlls:MoveToPosition(hHero, vEndPos)
    local modif = hHero:FindModifierByName("modifier_move_control")
    if modif then
        modif.vMovePoint = vEndPos
    end
end

function PlayersControlls:GetMoveDirection(hHero)
    local modif = hHero:FindModifierByName("modifier_move_control")
    if modif then
        local vNextPos = modif.vMovePoint
        local vPos = hHero:GetOrigin()
        if vNextPos == nil then return nil end
        return (vNextPos - vPos):Normalized()
    end
    return nil
end

function PlayersControlls:StopHeroForce(hHero)
    hHero:RemoveModifierByName("modifier_heroes_rift")
end

function PlayersControlls:ForceEndCooldown(hHero)
    local hAbility = hHero:FindAbilityByName("heroes_rift")
    if hAbility ~= nil then
        hAbility:EndCooldown()
    end
end

function PlayersControlls:Attack(hHero, vDirection, bProcs, bCooldown, bFakeAttack, nProjID)
    local modif = hHero:FindModifierByName("modifier_move_control")
    if modif then
        modif:Attack(vDirection, bProcs, bCooldown, bFakeAttack, nProjID)
    end
end

function PlayersControlls:Stop(hHero, bAll)
    local modif = hHero:FindModifierByName("modifier_move_control")
    if modif then
        modif.vMovePoint = nil
        if bAll then
            hHero.up = false
            hHero.down = false
            hHero.left = false
            hHero.right = false
            hHero.shoot = false
        end
    end
end

function PlayersControlls:FindPath(hHero, vStartPos, vEndPos)
    local Room = RoomGenerator:GetRoomByOrigin(hHero:GetOrigin())
    local ROOM_GRID = Room.Encounter.ROOM_GRID

    --Копирую таблицу гридов из энкаунтера
    local Grids = {}
    for _, Grid in ipairs(ROOM_GRID) do
        local t = {
            nSelfIndex = _,
            vOrigin = Grid.vOrigin,
            bMarkedCreated = Grid.bMarkedCreated,
            vMaxs = Grid.vMaxs,
            vMins = Grid.vMins,
            previous = nil,
        }
        table.insert(Grids, t)
    end

    --Беру начальный и конечный гриды
    local StartGrid = self:GetGridByOrigin(vStartPos, Grids)
    local EndGrid = self:GetGridByOrigin(vEndPos, Grids)

    --Если они существуют, то...
    if StartGrid ~= nil and EndGrid ~= nil then
        local Reachable = {StartGrid}
        local Explored = {}

        --Пока возможный путь существует
        while #Reachable > 0 do
            --Рандомный выбор следующего грида
            local Grid = self:ChooseGrid(Reachable)

            --Конечная точка найдена
            if Grid.nSelfIndex == EndGrid.nSelfIndex then
                return self:BuildPath(EndGrid)
            end

            --Текущий грид исследован
            table_remove_item(Reachable, Grid)
            table.insert(Explored, Grid)

            --Берём следующие гриды
            local NearGrids = self:GetNearGrids(Grid, Grids)
            if #NearGrids > 0 then
                for _, NewGrid in ipairs(NearGrids) do
                    if not IsInTable(Explored, NewGrid) and not IsInTable(Reachable, NewGrid) then
                        NewGrid.previous = Grid
                        table.insert(Reachable, NewGrid)
                    end
                end
            end
        end
    end

    return nil
end

function PlayersControlls:ChooseGrid(Reachable)
    return Reachable[RandomInt(1, #Reachable)]
end

function PlayersControlls:BuildPath(Grid)
    local path = {}

    local pGrid = Grid
    while pGrid ~= nil do
        table.insert(path, pGrid)
        pGrid = pGrid.previous
    end

    return path
end

function PlayersControlls:GetNearGrids(Grid, Grids)
    local NewGrids = {}
    for i=1, 4 do
        local vPos = Grid.vOrigin
        local NewGrid = self:GetGridByDirection(i, vPos, Grids)
        if NewGrid ~= nil and not NewGrid.bMarkedCreated then
            table.insert(NewGrids, NewGrid)
        end
    end

    return NewGrids
end

function PlayersControlls:GetGridByDirection(nDirection, vPos, Grids)
    local NewGrid = nil
    if nDirection == 1 then
        NewGrid = self:GetGridByOrigin(Vector(vPos.x-ROOM_GRID_SIZE, vPos.y, 0), Grids)
    elseif nDirection == 2 then
        NewGrid = self:GetGridByOrigin(Vector(vPos.x+ROOM_GRID_SIZE, vPos.y, 0), Grids)
    elseif nDirection == 3 then
        NewGrid = self:GetGridByOrigin(Vector(vPos.x, vPos.y+ROOM_GRID_SIZE, 0), Grids)
    elseif nDirection == 4 then
        NewGrid = self:GetGridByOrigin(Vector(vPos.x, vPos.y-ROOM_GRID_SIZE, 0), Grids)
    end

    return NewGrid
end

function PlayersControlls:GetGridByOrigin(vOrigin, Grids)
    for _, grid in pairs(Grids) do
        if RoomGenerator:IsInBounds( vOrigin, grid.vMaxs, grid.vMins ) then
            return grid
        end
    end

    return nil
end

PlayersControlls:Init()
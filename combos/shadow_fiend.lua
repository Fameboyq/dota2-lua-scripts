---
--- Shadow Fiend Combo Script (Eul + Requiem + Auto-Raze)
--- Framework: Umbrella / Lua 5.3
--- Author: Fameboyq (https://github.com/Fameboyq)
---

local SF = {}

SF.menu = Menu.Create("Heroes", "Shadow Fiend")
SF.enabled = Menu.AddToggle(SF.menu, "Enable SF Helper", true)
SF.eul_combo = Menu.AddKeybind(SF.menu, "Eul Combo Key", "F")
SF.auto_raze = Menu.AddToggle(SF.menu, "Auto Raze in Range", true)

-- Constants
local EUL_DURATION = 2.5
local REQUIEM_CAST_POINT = 1.67 -- Requiem cast time

function SF.OnUpdate()
    if not Menu.GetToggle(SF.enabled) then return end

    local my_hero = Heroes.GetLocal()
    if not my_hero or NPC.GetUnitName(my_hero) ~= "npc_dota_hero_nevermore" then return end

    local target = TargetSelector.GetBestTarget(my_hero, 1200)
    if not target then return end

    -- Eul + Requiem Execution
    if Menu.IsKeyDown(SF.eul_combo) then
        SF.ExecuteEulCombo(my_hero, target)
    end

    -- Auto Raze
    if Menu.GetToggle(SF.auto_raze) and not Menu.IsKeyDown(SF.eul_combo) then
        SF.ExecuteAutoRaze(my_hero, target)
    end
end

function SF.ExecuteEulCombo(my_hero, target)
    local eul = NPC.GetItem(my_hero, "item_cyclone") or NPC.GetItem(my_hero, "item_wind_waker")
    local ult = NPC.GetAbility(my_hero, "nevermore_requiem")

    if not eul or not ult or not Ability.IsCastable(ult, NPC.GetMana(my_hero)) then return end

    local eul_mod = NPC.GetModifier(target, "modifier_eul_cyclone")

    if not eul_mod and Ability.IsCastable(eul, NPC.GetMana(my_hero)) then
        -- Cast Eul on Target
        Ability.CastTarget(eul, target)
    elseif eul_mod then
        -- Target is in the air. Walk directly under target position
        local target_pos = Entity.GetAbsOrigin(target)
        local my_pos = Entity.GetAbsOrigin(my_hero)
        local dist = (target_pos - my_pos):Length2D()

        if dist > 25 then
            Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, target_pos, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, my_hero)
        else
            -- Timing calculation: Eul lasts 2.5s, Requiem takes 1.67s. Cast when remaining time == 1.67s
            local die_time = Modifier.GetDieTime(eul_mod)
            local time_left = die_time - GameRules.GetGameTime()

            if time_left <= REQUIEM_CAST_POINT + (NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) or 0.03) then
                Ability.CastNoTarget(ult)
            end
        end
    end
end

function SF.ExecuteAutoRaze(my_hero, target)
    local raze_q = NPC.GetAbility(my_hero, "nevermore_shadowraze1") -- 200
    local raze_w = NPC.GetAbility(my_hero, "nevermore_shadowraze2") -- 450
    local raze_e = NPC.GetAbility(my_hero, "nevermore_shadowraze3") -- 700

    local my_pos = Entity.GetAbsOrigin(my_hero)
    local target_pos = Entity.GetAbsOrigin(target)
    local dist = (target_pos - my_pos):Length2D()

    -- Check facing angle
    local my_facing = Entity.GetRotation(my_hero):GetForward()
    local dir_to_target = (target_pos - my_pos):Normalized()
    local dot = my_facing:Dot(dir_to_target)

    if dot > 0.92 then -- Almost directly in front
        if dist >= 100 and dist <= 300 and Ability.IsCastable(raze_q, NPC.GetMana(my_hero)) then
            Ability.CastNoTarget(raze_q)
        elseif dist >= 350 and dist <= 550 and Ability.IsCastable(raze_w, NPC.GetMana(my_hero)) then
            Ability.CastNoTarget(raze_w)
        elseif dist >= 600 and dist <= 800 and Ability.IsCastable(raze_e, NPC.GetMana(my_hero)) then
            Ability.CastNoTarget(raze_e)
        end
    end
end

return SF

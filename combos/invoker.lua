---
--- Invoker Eul One-Shot Combo Script
--- Framework: Umbrella / Lua 5.3
--- Author: Fameboyq (https://github.com/Fameboyq)
---

local Invoker = {}

Invoker.menu = Menu.Create("Heroes", "Invoker")
Invoker.enabled = Menu.AddToggle(Invoker.menu, "Enable Invoker Combo", true)
Invoker.eul_combo = Menu.AddKeybind(Invoker.menu, "Eul Combo Key", "G")

function Invoker.OnUpdate()
    if not Menu.GetToggle(Invoker.enabled) or not Menu.IsKeyDown(Invoker.eul_combo) then return end

    local my_hero = Heroes.GetLocal()
    if not my_hero or NPC.GetUnitName(my_hero) ~= "npc_dota_hero_invoker" then return end

    local eul = NPC.GetItem(my_hero, "item_cyclone") or NPC.GetItem(my_hero, "item_wind_waker")
    if not eul then return end

    local target = TargetSelector.GetBestTarget(my_hero, 1000)
    if not target then return end

    local eul_mod = NPC.GetModifier(target, "modifier_eul_cyclone")
    local my_mana = NPC.GetMana(my_hero)

    -- Step 1: Cast Eul
    if not eul_mod and Ability.IsCastable(eul, my_mana) then
        Ability.CastTarget(eul, target)
        return
    end

    -- Step 2: Target is in Cyclone
    if eul_mod then
        local target_pos = Entity.GetAbsOrigin(target)
        local time_left = Modifier.GetDieTime(eul_mod) - GameRules.GetGameTime()

        local ss = NPC.GetAbility(my_hero, "invoker_sun_strike")
        local meteor = NPC.GetAbility(my_hero, "invoker_chaos_meteor")
        local blast = NPC.GetAbility(my_hero, "invoker_deafening_blast")

        -- Sun Strike delay is 1.7s -> cast at time_left ~ 1.7s
        if ss and Ability.IsCastable(ss, my_mana) and time_left <= 1.75 and time_left > 1.6 then
            Ability.CastPosition(ss, target_pos)
            return
        end

        -- Chaos Meteor delay is 1.3s -> cast at time_left ~ 1.3s
        if meteor and Ability.IsCastable(meteor, my_mana) and time_left <= 1.35 and time_left > 1.2 then
            Ability.CastPosition(meteor, target_pos)
            return
        end

        -- Deafening Blast hits on landing -> cast right as target drops
        if blast and Ability.IsCastable(blast, my_mana) and time_left <= 0.2 then
            Ability.CastPosition(blast, target_pos)
            return
        end
    end
end

return Invoker

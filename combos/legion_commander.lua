---
--- Legion Commander Duel Combo Script
--- Framework: Umbrella / Lua 5.3
--- Author: Fameboyq (https://github.com/Fameboyq)
---

local LC = {}

LC.menu = Menu.Create("Heroes", "Legion Commander")
LC.enabled = Menu.AddToggle(LC.menu, "Enable LC Combo", true)
LC.combo_key = Menu.AddKeybind(LC.menu, "Duel Combo Key", "D")
LC.use_bkb = Menu.AddToggle(LC.menu, "Use BKB in Combo", true)
LC.use_blade_mail = Menu.AddToggle(LC.menu, "Use Blade Mail in Combo", true)

function LC.OnUpdate()
    if not Menu.GetToggle(LC.enabled) or not Menu.IsKeyDown(LC.combo_key) then return end

    local my_hero = Heroes.GetLocal()
    if not my_hero or NPC.GetUnitName(my_hero) ~= "npc_dota_hero_legion_commander" then return end

    local duel = NPC.GetAbility(my_hero, "legion_commander_duel")
    if not duel or not Ability.IsCastable(duel, NPC.GetMana(my_hero)) then return end

    local target = TargetSelector.GetBestTarget(my_hero, Ability.GetCastRange(duel) + 300)
    if not target or NPC.IsLinkensProtected(target) or NPC.HasModifier(target, "modifier_item_blade_mail") then return end

    local my_mana = NPC.GetMana(my_hero)
    local pta = NPC.GetAbility(my_hero, "legion_commander_press_the_attack")
    local bm = NPC.GetItem(my_hero, "item_blade_mail")
    local bkb = NPC.GetItem(my_hero, "item_black_king_bar")
    local blink = NPC.GetItem(my_hero, "item_blink") or NPC.GetItem(my_hero, "item_overwhelming_blink")

    -- 1. Buff Press The Attack
    if pta and Ability.IsCastable(pta, my_mana) and not NPC.HasModifier(my_hero, "modifier_legion_commander_press_the_attack") then
        Ability.CastTarget(pta, my_hero)
        return
    end

    -- 2. Activate Blade Mail
    if Menu.GetToggle(LC.use_blade_mail) and bm and Ability.IsCastable(bm, my_mana) then
        Ability.CastNoTarget(bm)
        return
    end

    -- 3. Activate BKB
    if Menu.GetToggle(LC.use_bkb) and bkb and Ability.IsCastable(bkb, my_mana) then
        Ability.CastNoTarget(bkb)
        return
    end

    -- 4. Blink to Target
    local my_pos = Entity.GetAbsOrigin(my_hero)
    local target_pos = Entity.GetAbsOrigin(target)
    local dist = (target_pos - my_pos):Length2D()

    if blink and Ability.IsCastable(blink, my_mana) and dist > 150 and dist <= 1200 then
        Ability.CastPosition(blink, target_pos)
        return
    end

    -- 5. Cast Duel
    if Ability.IsCastable(duel, my_mana) and dist <= Ability.GetCastRange(duel) + 50 then
        Ability.CastTarget(duel, target)
    end
end

return LC

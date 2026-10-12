---
--- Auto Items & Offensive Reaction Helper
--- Framework: Umbrella / Lua 5.3
--- Author: Fameboyq (https://github.com/Fameboyq)
---

local AutoItems = {}

AutoItems.menu = Menu.Create("Utilities", "Auto Items")
AutoItems.enabled = Menu.AddToggle(AutoItems.menu, "Enable Auto Items", true)
AutoItems.auto_hex = Menu.AddToggle(AutoItems.menu, "Instant Auto Hex/Silence", true)
AutoItems.auto_dagon = Menu.AddToggle(AutoItems.menu, "Auto Dagon on Lethal HP", true)

local DAGON_DAMAGE = { 400, 500, 600, 700, 800 }

function AutoItems.OnUpdate()
    if not Menu.GetToggle(AutoItems.enabled) then return end

    local my_hero = Heroes.GetLocal()
    if not my_hero or not Entity.IsAlive(my_hero) then return end

    local my_mana = NPC.GetMana(my_hero)
    local hex = NPC.GetItem(my_hero, "item_sheepstick")
    local orchid = NPC.GetItem(my_hero, "item_orchid") or NPC.GetItem(my_hero, "item_bloodthorn")
    local dagon = NPC.GetItem(my_hero, "item_dagon") or NPC.GetItem(my_hero, "item_dagon_2") or NPC.GetItem(my_hero, "item_dagon_3") or NPC.GetItem(my_hero, "item_dagon_4") or NPC.GetItem(my_hero, "item_dagon_5")

    local enemies = Heroes.GetAll()
    for _, enemy in ipairs(enemies) do
        if Entity.IsAlive(enemy) and not Entity.IsDormant(enemy) and not Entity.IsSameTeam(my_hero, enemy) then
            local dist = (Entity.GetAbsOrigin(enemy) - Entity.GetAbsOrigin(my_hero)):Length2D()

            -- 1. Auto Hex on Blink In / Channeling
            if Menu.GetToggle(AutoItems.auto_hex) and dist <= 800 and not NPC.IsLinkensProtected(enemy) then
                if NPC.IsChannellingAbility(enemy) or dist <= 450 then
                    if hex and Ability.IsCastable(hex, my_mana) and not NPC.HasModifier(enemy, "modifier_sheepstick_debuff") then
                        Ability.CastTarget(hex, enemy)
                        return
                    elseif orchid and Ability.IsCastable(orchid, my_mana) and not NPC.HasModifier(enemy, "modifier_orchid_malevolence_debuff") then
                        Ability.CastTarget(orchid, enemy)
                        return
                    end
                end
            end

            -- 2. Auto Dagon on Lethal Damage
            if Menu.GetToggle(AutoItems.auto_dagon) and dagon and Ability.IsCastable(dagon, my_mana) and dist <= 800 then
                local enemy_hp = Entity.GetHealth(enemy)
                local enemy_mag_res = NPC.GetMagicalArmorDamageMultiplier(enemy)
                local level = Ability.GetLevel(dagon)
                local raw_dmg = DAGON_DAMAGE[level] or 400
                local actual_dmg = raw_dmg * enemy_mag_res

                if enemy_hp <= actual_dmg and not NPC.IsLinkensProtected(enemy) and not NPC.HasModifier(enemy, "modifier_item_blade_mail") then
                    Ability.CastTarget(dagon, enemy)
                    return
                end
            end
        end
    end
end

return AutoItems

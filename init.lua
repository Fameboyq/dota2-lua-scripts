---
--- Dota 2 Lua Scripts Suite - Master Loader
--- Framework: Umbrella / Lua 5.3
--- Author: Fameboyq (https://github.com/Fameboyq)
---

local Scripts = {
    require("combos.shadow_fiend"),
    require("combos.legion_commander"),
    require("combos.invoker"),
    require("utilities.auto_items")
}

local Master = {}

function Master.OnUpdate()
    for _, script in ipairs(Scripts) do
        if script.OnUpdate then
            script.OnUpdate()
        end
    end
end

return Master

hook = {
    tmp_throw = {},
    tmp_throw_timer = 0,
    slingshot_entity_start_age = (
            tonumber(minetest.settings:get("item_entity_ttl") or 900) -
                    tonumber(minetest.settings:get("hook.slingshot_entity_ttl") or 10)
    ),
    pvp = minetest.settings:get_bool("enable_pvp") == true,
}

local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

dofile(mod_path .. "/thrown_hook.lua")
dofile(mod_path .. "/pchest.lua")

hook.punch = function(ob1, ob2, hp)
    ob2:punch(ob1, 1, { full_punch_interval = 1, damage_groups = { fleshy = hp } })
end

function hook.has_attr(pos, n)
    local def = minetest.registered_nodes[minetest.get_node(pos).name]
    return def and def[n]
end

function hook.can_hook(pos, player_name)
    if player_name and minetest.is_protected(pos, player_name) then
        return false
    else
        local def = minetest.registered_nodes[minetest.get_node(pos).name]
        if not def then return false end
        if def.name == "hook:hooking" then
            return minetest.get_meta(pos):get_int("a") == 0
        else
            return def.buildable_to and not (def.liquidtype == "source" and def.paramtype2 == "none")
        end
    end
end



minetest.register_node("hook:hooking", {
    description = "Hooking",
    drawtype = "mesh",
    mesh = "hook_hook.obj",
    tiles = { "hook_iron.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    walkable = false,
    pointable = false,
    drop = "",
    sunlight_propagates = false,
    groups = { not_in_creative_inventory = 1 },
    on_timer = function(pos, elapsed)
        local r = minetest.get_node({ x = pos.x, y = pos.y - 1, z = pos.z }).name
        if r ~= "hook:rope" then
            minetest.remove_node(pos)
            return false
        end
        return true
    end
})

minetest.register_tool("hook:mba", {
    description = "Mouth breather assembly",
    range = 1,
    inventory_image = "hook_mba.png",
    on_use = function(itemstack, user, pointed_thing)
        local pos = user:get_pos()
        pos.y = pos.y + 1.5
        if hook.has_attr(pos, "drowning") == 0 then
            itemstack:set_wear(1)
        else
            local use = itemstack:get_wear() + (65536 / 10)
            if use < 65536 then
                itemstack:set_wear(use)
                user:set_breath(11)
            end
        end
        return itemstack
    end
})

minetest.register_craft({
    output = "hook:mba",
    recipe = {
        { "", "default:steel_ingot", "" },
        { "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" },
        { "default:steel_ingot", "", "default:steel_ingot" },
    }
})

minetest.register_craft({
    output = "hook:hook",
    recipe = {
        { "", "default:steel_ingot", "" },
        { "", "default:steel_ingot", "default:steel_ingot" },
        { "default:steel_ingot", "", "" },
    }
})
minetest.register_craft({
    output = "hook:hook_upgrade",
    recipe = {
        { "", "hook:hook", "" },
        { "", "hook:hook", "" },
        { "", "default:steel_ingot", "" },
    }
})

minetest.register_craft({
    output = "hook:climb_rope",
    recipe = {
        { "", "default:steel_ingot", "" },
        { "", "default:steelblock", "" },
        { "", "default:steel_ingot", "" },
    }
})
minetest.register_craft({
    output = "hook:climb_rope_locked",
    recipe = {
        { "hook:climb_rope", "default:steel_ingot", "" },
    }
})

minetest.register_craft({
    output = "hook:slingshot",
    recipe = {
        { "default:steel_ingot", "", "default:steel_ingot" },
        { "", "default:steelblock", "" },
        { "", "default:steel_ingot", "" },
    }
})

minetest.register_globalstep(function(dtime)
    hook.tmp_throw_timer = hook.tmp_throw_timer + dtime
    if hook.tmp_throw_timer < 0.1 then
        return
    end
    hook.tmp_throw_timer = 0
    for i, t in pairs(hook.tmp_throw) do
        t.timer = t.timer - 0.25
        if t.timer <= 0 or t.ob == nil or t.ob:get_pos() == nil then
            table.remove(hook.tmp_throw, i)
            return
        end
        for ii, ob in pairs(minetest.get_objects_inside_radius(t.ob:get_pos(), 1.5)) do
            if (not ob:get_luaentity()) or (ob:get_luaentity() and (ob:get_luaentity().name ~= "__builtin:item")) then
                if (not ob:is_player()) or (ob:is_player() and ob:get_player_name(ob) ~= t.user and hook.pvp) then
                    ob:set_hp(ob:get_hp() - 5)
                    hook.punch(ob, ob, 4)
                    t.ob:set_velocity({ x = 0, y = 0, z = 0 })
                    if ob:get_hp() <= 0 and ob:is_player() == false then
                        ob:remove()
                    end
                    t.ob:set_acceleration({ x = 0, y = -10, z = 0 })
                    t.ob:set_velocity({ x = 0, y = -10, z = 0 })
                    table.remove(hook.tmp_throw, i)
                    break
                end
            end
        end
    end
end)

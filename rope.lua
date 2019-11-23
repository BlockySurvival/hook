minetest.register_node("hook:rope", {
    description = "Temporary Rope",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            { -0.0625, -0.5, -0.5, 0.0625, 0.5, -0.375 }
        }
    },
    tiles = { "hook_rope.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    buildable_to = true,
    drop = "",
    liquid_viscosity = 1,
    liquidtype = "source",
    liquid_alternative_flowing = "hook:rope",
    liquid_alternative_source = "hook:rope",
    liquid_renewable = false,
    liquid_range = 0,
    sunlight_propagates = false,
    walkable = false,
    is_ground_content = false,
    groups = { not_in_creative_inventory = 1, fleshy = 3, dig_immediate = 3, },
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(3)
    end,
    on_timer = function(pos, elapsed)
        for i, ob in pairs(minetest.get_objects_inside_radius(pos, 3)) do
            if ob:is_player() then
                return true
            end
        end
        minetest.set_node(pos, { name = "air" })
        return false
    end,
    sounds = { footstep = { name = "hook_rope", gain = 1 } }
})

minetest.register_node("hook:rope2", {
    description = "Rope",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            { -0.0625, -0.5, -0.5, 0.0625, 0.5, -0.375 }
        }
    },
    tiles = { "hook_rope.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    drop = "",
    liquid_viscosity = 1,
    liquidtype = "source",
    liquid_alternative_flowing = "hook:rope2",
    liquid_alternative_source = "hook:rope2",
    liquid_renewable = false,
    liquid_range = 0,
    sunlight_propagates = false,
    walkable = false,
    is_ground_content = false,
    groups = { not_in_creative_inventory = 1, fleshy = 3, dig_immediate = 3, },
    on_punch = function(pos, node, puncher, pointed_thing)
        if minetest.is_protected(pos, puncher:get_player_name()) then
            return false
        end
        puncher:get_inventory():add_item("main", ItemStack("hook:climb_rope"))
        local name = puncher:get_player_name()
        for i = 0, 20, 1 do
            if minetest.get_node({ x = pos.x, y = pos.y - i, z = pos.z }).name == "hook:rope2" or minetest.get_node({ x = pos.x, y = pos.y - i, z = pos.z }).name == "air" then
                minetest.set_node({ x = pos.x, y = pos.y - i, z = pos.z }, { name = "air" })
            else
                break
            end
        end
        for i = 0, 20, 1 do
            if minetest.get_node({ x = pos.x, y = pos.y + i, z = pos.z }).name == "hook:rope2" or minetest.get_node({ x = pos.x, y = pos.y + i, z = pos.z }).name == "hook:hooking" or minetest.get_node({ x = pos.x, y = pos.y + i, z = pos.z }).name == "air" then
                minetest.set_node({ x = pos.x, y = pos.y + i, z = pos.z }, { name = "air" })
            else
                return false
            end
        end
    end,
    sounds = { footstep = { name = "hook_rope", gain = 1 } }
})

minetest.register_node("hook:rope3", {
    description = "Rope (locked)",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            { -0.0625, -0.5, -0.5, 0.0625, 0.5, -0.375 }
        }
    },
    tiles = { "hook_rope.png" },
    paramtype = "light",
    paramtype2 = "facedir",
    drop = "",
    liquid_viscosity = 1,
    liquidtype = "source",
    liquid_alternative_flowing = "hook:rope3",
    liquid_alternative_source = "hook:rope3",
    liquid_renewable = false,
    liquid_range = 0,
    sunlight_propagates = false,
    walkable = false,
    is_ground_content = false,
    can_dig = function(pos, player)
        if minetest.get_meta(pos):get_string("owner") ~= player:get_player_name() then
            minetest.chat_send_player(player:get_player_name(), "This rope is owned by: " .. minetest.get_meta(pos):get_string("owner"))
            return false
        end
        return true
    end,
    groups = { not_in_creative_inventory = 1, fleshy = 3, dig_immediate = 3, },
    on_punch = function(pos, node, puncher, pointed_thing)
        if minetest.get_meta(pos):get_string("owner") ~= puncher:get_player_name() then
            minetest.chat_send_player(puncher:get_player_name(), "This rope is owned by: " .. minetest.get_meta(pos):get_string("owner"))
            return false
        end
        puncher:get_inventory():add_item("main", ItemStack("hook:climb_rope_locked"))
        for i = 0, 20, 1 do
            if minetest.get_node({ x = pos.x, y = pos.y - i, z = pos.z }).name == "hook:rope3" or minetest.get_node({ x = pos.x, y = pos.y - i, z = pos.z }).name == "air" then
                minetest.set_node({ x = pos.x, y = pos.y - i, z = pos.z }, { name = "air" })
            else
                break
            end
        end
        for i = 0, 20, 1 do
            if minetest.get_node({ x = pos.x, y = pos.y + i, z = pos.z }).name == "hook:rope3" or minetest.get_node({ x = pos.x, y = pos.y + i, z = pos.z }).name == "hook:hooking" or minetest.get_node({ x = pos.x, y = pos.y + i, z = pos.z }).name == "air" then
                minetest.set_node({ x = pos.x, y = pos.y + i, z = pos.z }, { name = "air" })
            else
                return false
            end
        end
    end,
    sounds = { footstep = { name = "hook_rope", gain = 1 } }
})

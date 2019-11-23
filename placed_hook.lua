minetest.register_tool("hook:hook", {
    description = "Hook with rope (hit a corner to climb)",
    inventory_image = "hook_hook.png",
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then
            return itemstack
        end
        local d = minetest.dir_to_facedir(user:get_look_dir())
        local pos = pointed_thing.above
        local pos2 = pointed_thing.under
        local name = user:get_player_name()

        if hook.has_attr(pos2, "walkable") and
                hook.has_attr({ x = pos.x, y = pos.y - 1, z = pos.z }, "walkable") == false
                and (hook.has_attr({ x = pos2.x, y = pos2.y + 1, z = pos2.z }, "walkable") == false or minetest.get_node({ x = pos2.x, y = pos2.y + 1, z = pos2.z }).name == "default:snow") and
                hook.can_hook(pos, name) and
                hook.has_attr({ x = pos.x, y = pos.y + 1, z = pos.z }, "walkable") == false then
            if d == 3 then
                d = 1
            elseif d == 1 then
                d = 3
            elseif d == 2 then
                d = 0
            elseif d == 0 then
                d = 2
            end
            if hook.can_hook({ x = pos.x, y = pos.y + 1, z = pos.z }, name) then
                minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "hook:hooking", param2 = d })
                minetest.get_node_timer({ x = pos.x, y = pos.y + 1, z = pos.z }):start(3)
            else
                return itemstack
            end
            for i = 0, -4, -1 do
                if hook.can_hook({ x = pos.x, y = pos.y + i, z = pos.z }, name) then
                    minetest.set_node({ x = pos.x, y = pos.y + i, z = pos.z }, { name = "hook:rope", param2 = d })
                else
                    return itemstack
                end
            end
        end
        return itemstack
    end
})

minetest.register_tool("hook:hook_upgrade", {
    description = "Hook with rope (double)",
    range = 6,
    inventory_image = "hook_hookup.png",
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then
            return itemstack
        end
        local d = minetest.dir_to_facedir(user:get_look_dir())
        local pos = pointed_thing.above
        local pos2 = pointed_thing.under
        local name = user:get_player_name()
        if hook.has_attr(pos2, "walkable") and
                hook.has_attr({ x = pos.x, y = pos.y - 1, z = pos.z }, "walkable") == false and
                (hook.has_attr({ x = pos2.x, y = pos2.y + 1, z = pos2.z }, "walkable") == false or minetest.get_node({ x = pos2.x, y = pos2.y + 1, z = pos2.z }).name == "default:snow") and
                hook.can_hook(pos, name) and
                hook.has_attr({ x = pos.x, y = pos.y + 1, z = pos.z }, "walkable") == false then
            if d == 3 then
                d = 1
            elseif d == 1 then
                d = 3
            elseif d == 2 then
                d = 0
            elseif d == 0 then
                d = 2
            end
            if hook.can_hook({ x = pos.x, y = pos.y + 1, z = pos.z }, name) then
                minetest.set_node({ x = pos.x, y = pos.y + 1, z = pos.z }, { name = "hook:hooking", param2 = d })
                minetest.get_node_timer({ x = pos.x, y = pos.y + 1, z = pos.z }):start(3)
            else
                return itemstack
            end
            for i = 0, -8, -1 do
                if hook.can_hook({ x = pos.x, y = pos.y + i, z = pos.z }, name) then
                    minetest.set_node({ x = pos.x, y = pos.y + i, z = pos.z }, { name = "hook:rope", param2 = d })
                else
                    return itemstack
                end
            end
        end
        return itemstack
    end
})

minetest.register_tool("hook:climb_rope", {
    description = "Climb rope",
    range = 2,
    inventory_image = "hook_rope2.png",
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then
            hook.user = user
            hook.locked = false
            local pos = user:get_pos()
            local d = user:get_look_dir()
            local m = minetest.add_entity({ x = pos.x, y = pos.y + 1.5, z = pos.z }, "hook:power")
            m:set_velocity({ x = d.x * 15, y = d.y * 15, z = d.z * 15 })
            m:set_acceleration({ x = 0, y = -5, z = 0 })
            minetest.sound_play("hook_throw", { pos = pos, gain = 1.0, max_hear_distance = 5, })
            return itemstack
        else
            local pos = pointed_thing.under
            local d = minetest.dir_to_facedir(user:get_look_dir())
            local z = 0
            local x = 0
            local name = user:get_player_name()
            if hook.has_attr(pos, "walkable") then
                if d == 0 then
                    z = 1
                end
                if d == 2 then
                    z = -1
                end
                if d == 1 then
                    x = 1
                end
                if d == 3 then
                    x = -1
                end
                if hook.can_hook({ x = pos.x + x, y = pos.y, z = pos.z + z }, name) and hook.can_hook({ x = pos.x + x, y = pos.y + 1, z = pos.z + z }, name) then
                    minetest.set_node({ x = pos.x + x, y = pos.y + 1, z = pos.z + z }, { name = "hook:hooking", param2 = d })
                    minetest.get_meta({ x = pos.x + x, y = pos.y + 1, z = pos.z + z }):set_int("a", 1)
                else
                    return itemstack
                end
                itemstack:take_item()
                for i = 0, 20, 1 do
                    if hook.can_hook({ x = pos.x + x, y = pos.y - i, z = pos.z + z }, name) then
                        minetest.set_node({ x = pos.x + x, y = pos.y - i, z = pos.z + z }, { name = "hook:rope2", param2 = d })
                    else
                        return itemstack
                    end
                end
            end
            return itemstack
        end
    end
})

minetest.register_tool("hook:climb_rope_locked", {
    description = "Climb rope (Locked)",
    range = 2,
    inventory_image = "hook_rope_locked.png",
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then
            hook.user = user
            hook.locked = true
            local pos = user:get_pos()
            local d = user:get_look_dir()
            local m = minetest.add_entity({ x = pos.x, y = pos.y + 1.5, z = pos.z }, "hook:power")
            m:set_velocity({ x = d.x * 15, y = d.y * 15, z = d.z * 15 })
            m:set_acceleration({ x = 0, y = -5, z = 0 })
            minetest.sound_play("hook_throw", { pos = pos, gain = 1.0, max_hear_distance = 5, })
            return itemstack
        else
            local pos = pointed_thing.under
            local d = minetest.dir_to_facedir(user:get_look_dir())
            local z = 0
            local x = 0
            local name = user:get_player_name()
            if hook.has_attr(pos, "walkable") then
                if d == 0 then
                    z = 1
                end
                if d == 2 then
                    z = -1
                end
                if d == 1 then
                    x = 1
                end
                if d == 3 then
                    x = -1
                end
                if hook.can_hook({ x = pos.x + x, y = pos.y, z = pos.z + z }, name) and hook.can_hook({ x = pos.x + x, y = pos.y + 1, z = pos.z + z }, name) then
                    minetest.set_node({ x = pos.x + x, y = pos.y + 1, z = pos.z + z }, { name = "hook:hooking", param2 = d })
                    minetest.get_meta({ x = pos.x + x, y = pos.y + 1, z = pos.z + z }):set_int("a", 1)
                else
                    return itemstack
                end
                itemstack:take_item()
                for i = 0, 20, 1 do
                    if hook.can_hook({ x = pos.x + x, y = pos.y - i, z = pos.z + z }, name) then
                        minetest.set_node({ x = pos.x + x, y = pos.y - i, z = pos.z + z }, { name = "hook:rope3", param2 = d })
                        minetest.get_meta({ x = pos.x + x, y = pos.y - i, z = pos.z + z }):set_string("owner", user:get_player_name())
                    else
                        return itemstack
                    end
                end
            end
            return itemstack
        end
    end
})


minetest.register_entity("hook:power", {
    hp_max = 100,
    physical = true,
    collisionbox = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
    visual = "mesh",
    mesh = "hook_hook.obj",
    visual_size = { x = 10, y = 10 },
    textures = { "hook_iron.png" },
    is_visible = true,
    makes_footstep_sound = false,
    automatic_rotate = false,
    timer2 = 0,
    d = 0,
    uname = "",
    locked = false,
    on_activate = function(self, staticdata)
        if hook.user == nil then
            self.object:remove()
            return self
        end
        self.user = hook.user
        self.uname = self.user:get_player_name()
        self.d = self.user:get_look_dir()
        self.locked = hook.locked
        self.fd = (minetest.dir_to_facedir(self.d) + 2) % 4
        hook.user = nil
    end,
    on_step = function(self, dtime)
        self.timer2 = self.timer2 + dtime
        local object = self.object
        local user = self.user
        local user_inv = user:get_inventory()
        local uname = self.uname
        local d = self.d
        local fd = self.fd

        local pos = object:get_pos()
        local kill = 0
        local va = { x = pos.x + d.x, y = pos.y,     z = pos.z + d.z }
        local vb = { x = pos.x + d.x, y = pos.y + 1, z = pos.z + d.z }
        local vc = { x = pos.x,       y = pos.y + 1, z = pos.z }

        if (        hook.has_attr(va, "walkable")
                and not hook.has_attr(vb, "walkable")
                and hook.can_hook(pos, uname)
                and hook.can_hook(vc, uname)) then
            kill = 1
            if self.locked then
                if not user_inv:contains_item("main", "hook:climb_rope_locked") then
                    object:remove()
                    return self
                end
                if hook.can_hook(vc, self.uname) then
                    minetest.set_node(vc, { name = "hook:hooking", param2 = fd })
                    minetest.get_meta(vc):set_int("a", 1)
                else
                    return self
                end
                user_inv:remove_item("main", "hook:climb_rope_locked")
                for i = 0, 20, 1 do
                    local vd = { x = pos.x, y = pos.y - i, z = pos.z }
                    if hook.can_hook(vd, uname) then
                        minetest.set_node(vd, { name = "hook:rope3", param2 = fd })
                    else
                        break
                    end
                    minetest.get_meta(vd):set_string("owner", uname)
                end
            else
                if not user_inv:contains_item("main", "hook:climb_rope") then
                    object:remove()
                    return self
                end
                if hook.can_hook(vc, uname) then
                    minetest.set_node(vc, { name = "hook:hooking", param2 = fd })
                    minetest.get_meta(vc):set_int("a", 1)
                else
                    return self
                end
                user_inv:remove_item("main", "hook:climb_rope")
                for i = 0, 20, 1 do
                    local vd = { x = pos.x, y = pos.y - i, z = pos.z }
                    if hook.can_hook(vd, uname) then
                        minetest.set_node(vd, { name = "hook:rope2", param2 = fd })
                    else
                        break
                    end
                end
            end
        end
        if self.timer2 > 3 or kill == 1 then
            object:remove()
        end
        return self
    end,
})

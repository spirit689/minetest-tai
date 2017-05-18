tai.build_formspec = function(player_name)
    local cfg = tai.player_config[player_name]
    -- print("player config: "..dump(cfg))
    formspec = { tai.inv.main(tai.config), tai.inv.pages(cfg) }
    for part, enabled in pairs(cfg.formspec) do
        if enabled == 1 then
            formspec[#formspec + 1] = tai.inv[part](cfg)
        end
    end
    return table.concat(formspec, "")
end

tai.setting_get = function(setting, default)
    local val = minetest.setting_get(setting)
    if val and val ~= '' then
        return val
    else
        return default
    end
end

tai.give_item = function (player, item)
    local player_name = player:get_player_name()
    local inventory = player:get_inventory()
    local s = ItemStack(item)
    inventory:add_item("main", {name = item, count = s:get_stack_max()})
end

tai.register_tab = function (def)
    tai.tabs[def.index] = def
    tai.inv.tabs = {}
    for i,def in ipairs(tai.tabs) do
        table.insert(tai.inv.tabs, def.name)
    end
end

tai.register_callback = function (field, action)
    if field and field ~= '' then
        if tai.callbacks[field] == nil then
            tai.callbacks[field] = {}
        end
        if type(action) == 'function' then
            table.insert(tai.callbacks[field], action)
        end
    end
end

tai.remove_callback = function (field)
    tai.callbacks[field] = nil
end

tai.do_callback = function (field, ...)
    if tai.callbacks[field] ~= nil then
        for _,cb in ipairs(tai.callbacks[field]) do
            cb(...)
        end
    end
end

tai.is_allowed_item = function(name)
    local l = tai.config.whitelist
    for _,v in ipairs(l) do
        if name:find(v, 1, true) then
            return true
        end
    end
    return false
end

tai.init_player = function(player_name)
    tai.player_config[player_name] = {
        player_name = player_name,
        page = 0,
        filter = '',
        tab = 1,
        category = 0,
        formspec = {
            player = 1,
            craft = 1
        }
    }
end

tai.inv_button = function (id, x, y, caption)
    return 'image_button['..tostring(x)..','..tostring(y)..';0.9,0.85;tai_slot.png;'..id..';'..minetest.formspec_escape(caption)..';false;false;tai_slot_active.png]'
end

-- return small grid (10x9) coords
tai.inv_coords = function (args)
    local dx, dy = 0.792, 0.9
    local maxx, maxy = 9, 8
    local coords = {}
    if args.x then
        if type(args.x) == 'string' then
            if args.x == 'left' then
                coords.x = 0
            elseif args.x == 'right' then
                coords.x = dx * maxx
            else
                coords.x = 0
            end
        else
            coords.x = dx * args.x
        end
    end
    if args.y then
        if type(args.x) == 'string' then
            if args.y == 'top' then
                coords.y = 0
            elseif args.y == 'bottom' then
                coords.y = dy * maxy
            else
                coords.y = 0
            end
        else
            coords.y = dy * args.y
        end
    end
    return coords
end

tai.init = function ()
    local count = 0
    local modname = ''
    local modnames = {}

    if minetest.get_modpath('sfinv') and sfinv then
        sfinv.enabled = false
    end
    for name,def in pairs(minetest.registered_items) do
        if name ~= '' then
            if not (def.groups.not_in_creative_inventory == 1) or tai.is_allowed_item(name) then
                modname = name:match('(.+):')
                if modname and modname ~= "" and modnames[modname] == nil then
                    modnames[modname] = 1
                end
                table.insert(tai.items,name)
                count = count + 1
            end
        end
    end
    for k,v in pairs(modnames) do
        table.insert(tai.mods,k)
    end
    table.sort(tai.mods)
    tai.config.total = count
    minetest.log("info","[TAI] Found "..count.." registered items in "..#tai.mods.." mods.")
end

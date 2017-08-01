tai.settings = {}
tai.settings.get = function (self, setting, default)
    local val = minetest.settings:get(setting)
    if val and val ~= '' then
        return val
    else
        return default
    end
end

tai.settings.get_data = function (self, player_name)
    local player = minetest.get_player_by_name(player_name)
    local data
    if player then
        data = minetest.deserialize(player:get_attribute('tai:data'))
    end
    return data
end

tai.settings.save_data = function (self, player_name)
    local player = minetest.get_player_by_name(player_name)
    player:set_attribute('tai:data', minetest.serialize(tai.player_config[player_name]))
end

tai.build_formspec = function(player_name)
    local cfg = tai.player_config[player_name]
    -- print("player config: "..dump(cfg))
    local formspec = { tai.inv.main(tai.config), tai.inv.pages(cfg) }
    for part, enabled in pairs(cfg.formspec) do
        if enabled == 1 then
            formspec[#formspec + 1] = tai.inv[part](cfg)
        end
    end
    return table.concat(formspec, "")
end

tai.register_tab = function (def)
    tai.tabs[def.index] = def
    tai.inv.tabs = {}
    for i,def in ipairs(tai.tabs) do
        table.insert(tai.inv.tabs, def.name)
    end
end

tai.add_action = function (action, func)
    if action and action ~= '' then
        local actions = action:split(' ')
        for i, a in ipairs(actions) do
            if tai.callbacks[a] == nil then
                tai.callbacks[a] = {}
            end
            if type(func) == 'function' then
                table.insert(tai.callbacks[a], func)
            end
        end
    end
end

tai.remove_action = function (action)
    tai.callbacks[action] = nil
end

tai.do_action = function (action, ...)
    if tai.callbacks[action] ~= nil then
        for _,cb in ipairs(tai.callbacks[action]) do
            cb(...)
        end
    end
end

tai.apply_filter = function (action, ...)
    if tai.callbacks[action] ~= nil then
        return tai.do_action(action, ...)
    else
        return ...
    end
end

tai.init_player = function(player_name)
    local data = tai.settings:get_data(player_name)
    if data then
        tai.player_config[player_name] = data
    else
        tai.player_config[player_name] = {
            player_name = player_name,
            page = 0,
            filter = '',
            tab = 1,
            category = 0,
            formspec = {
                player = 1,
                craft = 1
            },
            recipe = {
                typeindex = 1,
                index = 1
            }
        }
    end
end

tai.init_items = function ()
    local count = 0
    local modname = ''
    local modnames = {}
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
    table.sort(tai.items)
    table.sort(tai.mods)
    tai.config.total = count
    print("[TAI] Found "..count.." registered items in "..#tai.mods.." mods.")
end

tai.init_groups = function ()
    local def
    for _, name in ipairs(tai.items) do
        def = minetest.registered_items[name]
        if def.groups then
            for group, val in pairs(def.groups) do
                if tai.groups[group] == nil then
                    tai.groups[group] = name
                end
            end
        end
    end
end

tai.init = function ()
    if minetest.get_modpath('sfinv') and sfinv then
        sfinv.enabled = false
    end
    local t1 = os.clock()
    tai.init_items()
    tai.init_groups()
    tai.do_action('init', tai.config)
    print("[TAI] Loaded in "..tostring(os.clock() - t1))
end

tai.get_items_in_group = function (groups)
	local items = {}
    local def
    local check
	for index, itemname in ipairs(tai.items) do
        def = minetest.registered_items[itemname]
        check = true
        for i, g in ipairs(groups) do
            if not def.groups[g] then
                check = false
            end
        end
        if check == true then
            items[#items + 1] = itemname
        end
	end
	return items
end

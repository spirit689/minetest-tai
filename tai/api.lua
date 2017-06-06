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

tai.setting_get = function(setting, default)
    local val = minetest.setting_get(setting)
    if val and val ~= '' then
        return val
    else
        return default
    end
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
        if tai.callbacks[action] == nil then
            tai.callbacks[action] = {}
        end
        if type(func) == 'function' then
            table.insert(tai.callbacks[action], func)
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
    minetest.log("info","[TAI] Found "..count.." registered items in "..#tai.mods.." mods.")
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
    tai.init_items()
    tai.init_groups()
    tai.do_action('init', tai.config)
end

tai.get_items_in_group = function (group)
	local items = {}
    local def
	for index, itemname in ipairs(tai.items) do
        def = minetest.registered_items[itemname]
		if def.groups[group] then
            items[#items + 1] = itemname
        end
	end
	return items
end

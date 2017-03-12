-- Minetest mod tai
-- Version: 0.1.0

tai = {}
tai.config = {}
tai.player_config = {}
tai.modnames = {}
tai.itemlist = {}
tai.tabs = {
    'Main',
    'Items'
}

local path = minetest.get_modpath(minetest.get_current_modname())
dofile(path..'/gui.lua')

tai.init = function (player)
    local count = 0
    local modname = ''
    local modnames = {}

    tai.config.delay = tai.setting_get('tai_delay_time', 5)
    tai.config.modlist = minetest.setting_get('tai_modlist') == 'true'
    tai.config.whitelist = tai.setting_get('tai_filters', ''):split(',')

    for name,def in pairs(minetest.registered_items) do
        if name ~= '' then
            if not (def.groups.not_in_creative_inventory == 1) or tai.is_allowed_item(tai.config, name) then
                modname = name:match('(.+):')
                if modname and modname ~= "" and modnames[modname] == nil then
                    modnames[modname] = 1
                end
                table.insert(tai.itemlist,name)
                count = count + 1
            end
        end
    end
    for k,v in pairs(modnames) do
        table.insert(tai.modnames,k)
    end
    table.sort(tai.modnames)
    tai.config.total = count
    print("[TAI] Found "..count.." registered items in "..#tai.modnames.." mods.")

    -- 3d_armor
    -- override armor.update_inventory to see preview changes
    tai.config.armor = false
    if minetest.get_modpath("3d_armor") ~= nil then
        tai.config.armor = true
    end
    if armor and tai.config.armor == true then
        ---
        armor.update_inventory = function (self, player)
            local name = armor:get_valid_player(player, "[set_player_armor]")
            if not name or not tai.player_config[name] then
                return
            else
                player:set_inventory_formspec(tai.build_formspec(name))
            end
        end
        ---
    end

end

tai.is_allowed_item = function(cfg, name)
    local l = cfg.whitelist
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
        -- item list
        page = 0,
        cols = 9,
        rows = 4,
        -- search filter
        filter = '',
        -- show mod list
        modlist = 0,
        -- selected mod
        category = 1,
        -- current tab
        tab = 1
    }
end

tai.build_formspec = function(player_name)
    local cfg = tai.player_config[player_name]
    local formspec = {}

    formspec = { tai.gui_main(cfg), tai.gui_tabs(cfg) }

    if cfg.itemlist == 1 then
        formspec[#formspec+1] = tai.gui_items(cfg)
        formspec[#formspec+1] = tai.gui_search(cfg)
    else
        if tai.config.armor == true then
            formspec[#formspec+1] = tai.gui_craftequip(cfg)
        else
            formspec[#formspec+1] = tai.gui_craft()
        end
    end

    if cfg.modlist == 1 then
        formspec[#formspec+1] = tai.gui_mods(cfg)
    end

    formspec[#formspec+1] = tai.gui_player()

    return table.concat(formspec, "")
end

tai.texlist_event = function (str)
    local e = {}
    e.type = str:sub(1, str:find(':', 1, true)-1)
    e.row = str:sub(str:find(':', 1, true)+1)
    return e
end

tai.setting_get = function(setting, default)
    local val = minetest.setting_get(setting)
    if val and val ~= '' then
        return val
    else
        return default
    end
end

tai.give_item = function (player, item, count)
    local player_name = player:get_player_name()
    local inventory = player:get_inventory()
    local s = ItemStack(item)

    if tonumber(count) == 0 then return end
    inventory:add_item("main", {name = item, count = s:get_stack_max()})
end

local trash = minetest.create_detached_inventory("tai_trash", {
	allow_put = function(inv, listname, index, stack, player)
		return stack:get_count()
	end,
	on_put = function(inv, listname)
		inv:set_list(listname, {})
	end,
})
trash:set_size("main", 1)

minetest.register_on_joinplayer(function(player)
    minetest.after(tai.config.delay, function()
        minetest.chat_send_player(player:get_player_name(), "TAI: Initialized")
        tai.init_player(player:get_player_name())
        player:set_inventory_formspec(tai.build_formspec(player:get_player_name()))
    end)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    local cfg = tai.player_config[name]
    local evt = {}

    if fields["quit"] then return end

    if fields["tai_next"] then
        cfg.page = cfg.page + 1
    elseif fields["tai_prev"] then
        cfg.page = cfg.page - 1
    elseif fields["tai_togglemods"] then
        if cfg.modlist == 1 then
            cfg.modlist = 0
        else
            cfg.modlist = 1
        end
    elseif fields["tai_settings"] then
        minetest.chat_send_player(name, "WIP")
    elseif fields["tai_search"] and fields["key_enter"] == "true" and fields["key_enter_field"] == "tai_search" then
        if cfg.filter ~= fields["tai_search"] then
            cfg.filter = fields["tai_search"]
        else
            cfg.filter = ''
        end
        cfg.page = 0
        cfg.itemlist = 1
    elseif fields["tai_mod"] then
        if fields["tai_mod"] ~= '' then
            evt = tai.texlist_event(fields["tai_mod"])
            -- evt = minetest.explode_table_event(fields["tai_mod"]) -- =(
            if evt.type == "DCL" then
                cfg.filter = tai.modnames[tonumber(evt.row)]
                cfg.category = evt.row
                cfg.itemlist = 1
                cfg.tab = 2
                cfg.page = 0
            end
        end
    elseif fields["tai_tab"] then
        cfg.tab = tonumber(fields["tai_tab"])
        if cfg.tab == 1 then
            cfg.itemlist = 0
        elseif cfg.tab == 2 then
            cfg.itemlist = 1
        end
    elseif fields["tai_resetsearch"] then
        cfg.filter = ''
    end

    for field, val in pairs(fields) do
        if field:find('tai_give:', 1, true) then
            tai.give_item(player, field:sub(field:find(':', 1, true)+1))
        end
    end
    player:set_inventory_formspec(tai.build_formspec(name))
end)

minetest.after(0, tai.init)

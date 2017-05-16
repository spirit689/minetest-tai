tai = {}
tai.config = {}
tai.player_config = {}
tai.mods = {}
tai.items = {}
tai.tabs = {}
tai.callbacks = {}

local path = minetest.get_modpath(minetest.get_current_modname())
dofile(path..'/api.lua')
dofile(path..'/inv.lua')

tai.config.delay = tai.setting_get('tai_delay_time', 5)
tai.config.whitelist = tai.setting_get('tai_filters', ''):split(',')
tai.config.bgcolor = tai.setting_get('tai_bgcolor', '#21252BFF')
tai.config.slot_bg = tai.setting_get('tai_slot_bg', '#282C34FF')
tai.config.slot_bg_hover = tai.setting_get('tai_slot_bg_hover', '#2C323CFF')
tai.config.slot_border = tai.setting_get('tai_slot_border', '#181A1FFF')
tai.config.tooltip = tai.setting_get('tai_tooltip', '#FFFFFFFF')
tai.config.tooltip_bg = tai.setting_get('tai_tooltip_bg', '#66666666')

tai.register_tab({
    index = 1,
    name = 'Main',
})

tai.register_tab({
    index = 2,
    name = 'Items',
})

tai.register_callback('tai_prev', function(cfg, player, fields)
    cfg.page = cfg.page - 1
end)

tai.register_callback('tai_next', function(cfg, player, fields)
    cfg.page = cfg.page + 1
end)

tai.register_callback('tai_showmods', function(cfg, player, fields)
    cfg.formspec.mods = 1
    cfg.formspec.items = 0
    cfg.formspec.player = 0
end)

tai.register_callback('tai_mod', function(cfg, player, fields)
    if fields["tai_mod"] ~= '' then
        evt = minetest.explode_table_event(fields["tai_mod"])
        if evt.type == "DCL" then
            cfg.filter = tai.mods[tonumber(evt.row)]
            cfg.category = evt.row
            cfg.formspec.items = 1
            cfg.formspec.player = 1
            cfg.formspec.mods = 0
            cfg.tab = 2
            cfg.page = 0
        end
    end
end)

tai.register_callback('tai_search', function(cfg, player, fields)
    if fields["key_enter"] == "true" and fields["key_enter_field"] == "tai_search" then
        if cfg.filter ~= fields["tai_search"] then
            cfg.filter = fields["tai_search"]
        else
            cfg.filter = ''
        end
        cfg.page = 0
        cfg.formspec.items = 1
    end
end)

tai.register_callback('tai_tab', function(cfg, player, fields)
    cfg.tab = tonumber(fields["tai_tab"])
    if cfg.tab == 1 then
        cfg.formspec.items = 0
        cfg.formspec.craft = 1
        cfg.formspec.player = 1
    elseif cfg.tab == 2 then
        cfg.formspec.items = 1
        cfg.formspec.craft = 0
        cfg.formspec.player = 1
    end
end)

tai.register_callback('tai_resetsearch', function(cfg, player, fields)
    cfg.filter = ''
end)

tai.register_callback('receive_fields', function(cfg, player, fields)
    for field, val in pairs(fields) do
        if field:find('tai_item:', 1, true) then
            tai.give_item(player, field:sub(field:find(':', 1, true)+1))
        end
    end
end)

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
        local name = player:get_player_name()
        minetest.chat_send_player(player:get_player_name(), "TAI: Initialized")
        tai.init_player(name)
        tai.do_callback('init_player', tai.player_config[name], player, {})
        player:set_inventory_formspec(tai.build_formspec(player:get_player_name()))
    end)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    local cfg = tai.player_config[name]
    local evt = {}
    if fields['quit'] then return end
    tai.do_callback('receive_fields', cfg, player, fields)
    for field,val in pairs(fields) do
        if tai.callbacks[field] then
            for _,cb in ipairs(tai.callbacks[field]) do
                cb(cfg, player, fields)
            end
        end
    end
    player:set_inventory_formspec(tai.build_formspec(name))
end)

minetest.after(0, tai.init)

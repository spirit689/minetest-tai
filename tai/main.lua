tai.register_tab({
    index = 1,
    id = 'main:default',
    name = 'Main'
})

tai.register_tab({
    index = 2,
    id = 'items:default',
    name = 'Items'
})

tai.register_tab({
    index = 2,
    id = 'items:recipe',
    name = 'Items'
})

tai.register_tab({
    index = 2,
    id = 'items:search_mod',
    name = 'Items'
})

tai.register_tab({
    index = 3,
    id = 'settings:default',
    name = 'Settings'
})

tai.add_action('init_player', function (cfg)
    if not cfg.tabs then
        cfg.tabs = { 'main:default', 'items:default', 'settings:default'}
    end
end)

tai.add_action('tai_prev', function(cfg, player, fields)
    cfg.page = cfg.page - 1
end)

tai.add_action('tai_next', function(cfg, player, fields)
    cfg.page = cfg.page + 1
end)

tai.add_action('tai_showmods', function(cfg, player, fields)
    cfg.oldfilter = cfg.filter
    cfg.tab = 'items:search_mod'
end)

tai.add_action('tai_mod', function(cfg, player, fields)
    if fields["tai_mod"] ~= '' then
        evt = minetest.explode_table_event(fields["tai_mod"])
        if evt.type == "CHG" then
            cfg.filter = tai.mods[tonumber(evt.row)]
            cfg.category = evt.row
        end
        if evt.type == "DCL" then
            cfg.page = 0
            cfg.tab = 'items:default'
        end
    end
end)

tai.add_action('tai_modsearch', function(cfg, player, fields)
    cfg.page = 0
    cfg.tab = 'items:default'
end)

tai.add_action('tai_modcancel', function(cfg, player, fields)
    cfg.filter = cfg.oldfilter
    cfg.page = 0
    cfg.tab = 'items:default'
end)

tai.add_action('tai_search', function(cfg, player, fields)
    if fields["key_enter"] == "true" and fields["key_enter_field"] == "tai_search" then
        if cfg.filter ~= fields["tai_search"] then
            cfg.filter = fields["tai_search"]
        else
            cfg.filter = ''
        end
        cfg.page = 0
    end
end)

tai.add_action('tai_tab', function(cfg, player, fields)
    cfg.tab = cfg.tabs[tonumber(fields["tai_tab"])]
end)

tai.add_action('tai_tab_switch', function (cfg)
    cfg.tab = tai.apply_filter('tai_tab_name', cfg.tab)
    local index = tai.tabs[cfg.tab].index
    for part, enabled in pairs(cfg.formspec) do
        if enabled == 1 then
            cfg.formspec[part] = 0
        end
    end
    cfg.tabs[index] = cfg.tab
    if cfg.tab == 'main:default' then
        cfg.formspec.craft = 1
        cfg.formspec.player = 1
    elseif cfg.tab == 'items:default' then
        cfg.formspec.items = 1
        cfg.formspec.player = 1
    elseif cfg.tab == 'items:recipe' then
        cfg.formspec.recipe = 1
    elseif cfg.tab == 'items:search_mod' then
        cfg.formspec.mods = 1
    elseif cfg.tab == 'settings:default' then
        cfg.formspec.settings = 1
    end
end)

tai.add_action('tai_resetsearch', function(cfg, player, fields)
    cfg.filter = ''
end)

tai.add_action('receive_fields', function(cfg, player, fields)
    for field, val in pairs(fields) do
        if field:find('tai_item:', 1, true) then
            tai.do_action('tai_item', cfg, player, {item=field:sub(field:find(':', 1, true)+1)})
        elseif field:find('tai_give:', 1, true) then
            tai.do_action('tai_give', cfg, player, {item=field:sub(field:find(':', 1, true)+1)})
        elseif field:find('tai_crafttype:', 1, true) then
            tai.do_action('tai_crafttype', cfg, player, {typeindex=field:sub(field:find(':', 1, true)+1)})
        end
    end
end)

tai.add_action('tai_item', function (cfg, player, fields)
    local craft_item = fields.item
    if tai.craft_recipe[craft_item] and cfg.recipe.enabled then
        cfg.recipe.item = craft_item
        cfg.tab = 'items:recipe'
    else
        if minetest.check_player_privs(player, {creative = true}) and not craft_item:find('group:', 1, true) then
            tai.give_item(player, fields.item)
        end
    end
end)

tai.add_action('tai_give', function (cfg, player, fields)
    tai.give_item(player, fields.item)
end)

tai.add_action('tai_setting_recipe', function(cfg, player, fields)
    if cfg.recipe.enabled then
        cfg.recipe.enabled = false
    else
        cfg.recipe.enabled = true
    end
end)

tai.add_action('tai_setting_creative', function(cfg, player, fields)
    local privs = minetest.get_player_privs(cfg.player_name)
    if privs.creative then
        privs.creative = nil
    else
        privs.creative = true
    end
    minetest.set_player_privs(cfg.player_name, privs)
end)

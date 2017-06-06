tai.register_tab({
    index = 1,
    name = 'Main',
})

tai.register_tab({
    index = 2,
    name = 'Items',
})

tai.register_tab({
    index = 3,
    name = 'Settings',
})

tai.add_action('tai_prev', function(cfg, player, fields)
    cfg.page = cfg.page - 1
end)

tai.add_action('tai_next', function(cfg, player, fields)
    cfg.page = cfg.page + 1
end)

tai.add_action('tai_showmods', function(cfg, player, fields)
    cfg.oldfilter = cfg.filter
    cfg.formspec.mods = 1
    cfg.formspec.items = 0
    cfg.formspec.player = 0
end)

tai.add_action('tai_mod', function(cfg, player, fields)
    if fields["tai_mod"] ~= '' then
        evt = minetest.explode_table_event(fields["tai_mod"])
        if evt.type == "CHG" then
            cfg.filter = tai.mods[tonumber(evt.row)]
            cfg.category = evt.row
        end
        if evt.type == "DCL" then
            cfg.formspec.items = 1
            cfg.formspec.player = 1
            cfg.formspec.mods = 0
            cfg.page = 0
        end
    end
end)

tai.add_action('tai_modsearch', function(cfg, player, fields)
    cfg.formspec.items = 1
    cfg.formspec.player = 1
    cfg.formspec.mods = 0
    cfg.page = 0
end)

tai.add_action('tai_modcancel', function(cfg, player, fields)
    cfg.filter = cfg.oldfilter
    cfg.formspec.items = 1
    cfg.formspec.player = 1
    cfg.formspec.mods = 0
    cfg.page = 0
end)

tai.add_action('tai_search', function(cfg, player, fields)
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

tai.add_action('tai_tab', function(cfg, player, fields)
    cfg.tab = tonumber(fields["tai_tab"])
    for part, enabled in pairs(cfg.formspec) do
        if enabled == 1 then
            cfg.formspec[part] = 0
        end
    end
    if cfg.tab == 1 then
        cfg.formspec.craft = 1
        cfg.formspec.player = 1
    elseif cfg.tab == 2 then
        cfg.formspec.items = 1
        if cfg.recipe.show and cfg.recipe.enabled then
            cfg.formspec.recipe = 1
            cfg.formspec.items = 0
            cfg.formspec.player = 0
        else
            cfg.formspec.player = 1
        end
    elseif cfg.tab == 3 then
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
        end
    end
end)

tai.add_action('tai_item', function (cfg, player, fields)
    local craft_item = fields.item
    if tai.craft_recipe[craft_item] and cfg.recipe.enabled then
        cfg.formspec.player = 0
        cfg.formspec.items = 0
        cfg.formspec.recipe = 1
        cfg.recipe.show = true
        cfg.recipe.item = craft_item
    else
        if minetest.check_player_privs(player, {creative = true}) then
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

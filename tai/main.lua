tai.register_tab({
    index = 1,
    name = 'Main',
})

tai.register_tab({
    index = 2,
    name = 'Items',
})

tai.add_action('tai_prev', function(cfg, player, fields)
    cfg.page = cfg.page - 1
end)

tai.add_action('tai_next', function(cfg, player, fields)
    cfg.page = cfg.page + 1
end)

tai.add_action('tai_showmods', function(cfg, player, fields)
    cfg.formspec.mods = 1
    cfg.formspec.items = 0
    cfg.formspec.player = 0
end)

tai.add_action('tai_mod', function(cfg, player, fields)
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
        cfg.formspec.player = 1
    end
end)

tai.add_action('tai_resetsearch', function(cfg, player, fields)
    cfg.filter = ''
end)

tai.add_action('receive_fields', function(cfg, player, fields)
    for field, val in pairs(fields) do
        if field:find('tai_item:', 1, true) then
            tai.do_action('tai_item', cfg, player, {item=field:sub(field:find(':', 1, true)+1)})
        end
    end
end)

tai.add_action('tai_item', function (cfg, player, fields)
    if minetest.check_player_privs(player, {creative = true}) then
        tai.give_item(player, fields.item)
    end
end)

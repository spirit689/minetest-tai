local inv = tai.inv

-- inventory

inv.armor = function(cfg)
    local formspec = {}
    formspec[#formspec+1] = 'list[detached:'..cfg.player_name..'_armor;armor;0,0.25;1,4;]'
    formspec[#formspec+1] = 'list[detached:'..cfg.player_name..'_armor;armor;1,3.25;2,1;4]'
    formspec[#formspec+1] = 'image[1.22,0.3;1.7,3.2;'..armor.textures[cfg.player_name].preview..']'
    formspec[#formspec+1] = 'image_button[1,0.25;2,3;tai_player_bg.png;tai_togglearmor;]'
    return table.concat(formspec, '')
end

inv.armorstats = function(cfg)
    local stats = armor.def[cfg.player_name];
    local formspec = {}
    local h = 0.2
    local def = {
        { stats.level, 'tai_chestplate.png' },
        { stats.heal, 'tai_heart.png' }
    }
    if minetest.global_exists("technic") and stats.groups["radiation"] then
        def[#def + 1] = { stats.groups["radiation"], 'tai_rad.png' }
    end
    if armor.config.fire_protect then
        def[#def + 1] = { stats.fire, 'tai_fire.png' }
    end
    for i,v in ipairs(def) do
        formspec[#formspec+1] = 'image[3,'..tostring(h + 0.05)..';0.4,0.4;'..v[2]..']'
        formspec[#formspec+1] = 'label[3.4,'..tostring(h)..';'..v[1]..']'
        h = h + 0.5
    end
    formspec[#formspec+1] = 'list[detached:tai_trash;main;7,3.25;1,1;]'
    return table.concat(formspec, '')
end

inv.armorcraft = function()
    local formspec = "list[current_player;craft;3,0.25;3,3;]"..
        "listring[current_player;craft]"..
        "list[detached:tai_trash;main;7,3.25;1,1;]"..
        "list[current_player;craftpreview;6,1.25;1,1;]"
    return formspec
end

-- callbacks

tai.add_action('tai_togglearmor', function (cfg, player, fields)
    if cfg.formspec.armorstats == 1 then
        cfg.formspec.armorcraft = 1
        cfg.formspec.armorstats = 0
    else
        cfg.formspec.armorcraft = 0
        cfg.formspec.armorstats = 1
    end
end)

tai.add_action('tai_tab init_player', function (cfg, player, fields)
    if cfg.tab == 1 then
        cfg.formspec.craft = 0
        cfg.formspec.armor = 1
        cfg.formspec.armorcraft = 1
    end
end)

armor:register_on_update(function(player)
    local name = player:get_player_name()
    if not name or not tai.player_config[name] then
        return
    else
        player:set_inventory_formspec(tai.build_formspec(name))
    end
end)

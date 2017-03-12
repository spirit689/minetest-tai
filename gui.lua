-- formspec parts
tai.gui_main = function(cfg)
    local formspec = {}

    if cfg and cfg.modlist == 1 then
        formspec[#formspec+1] = "size[11,8.6]"
    else
        formspec[#formspec+1] = "size[8,8.6]"
    end

    formspec[#formspec+1] = 'bgcolor[#21252BFF;false]'
    formspec[#formspec+1] = 'listcolors[#282C34FF;#2C323CFF;#181A1FFF;#4D78CCFF;#FFFFFFFF]'
    if tai.config.modlist == true then
        if cfg and cfg.modlist == 1 then
            formspec[#formspec+1] = 'image_button[7.5,0;0.6,0.85;tai_hide.png;tai_togglemods;]'
            formspec[#formspec+1] = 'tooltip[tai_togglemods;Hide mods]'
        else
            formspec[#formspec+1] = 'image_button[7.5,0;0.6,0.85;tai_show.png;tai_togglemods;]'
            formspec[#formspec+1] = 'tooltip[tai_togglemods;Show mods]'
        end
    end

    return table.concat(formspec, "")
end

tai.gui_tabs = function(cfg)
    local formspec = {'tabheader[0,0;tai_tab;'}
    formspec[#formspec+1] = table.concat(tai.tabs, ',')
    formspec[#formspec+1] = ';'..cfg.tab..';true;false]'
    return table.concat(formspec, "")
end

tai.gui_player = function()
    return "list[current_player;main;0,4.75;8,1;]"..
    "list[current_player;main;0,5.9;8,3;8]"..
    "listring[current_player;main]"..
    default.get_hotbar_bg(0,4.75)
end

tai.gui_craft = function()
    -- formspec[#formspec+1] = 'list[detached:tai_trash;main;0,0;1,1;]'
    return "list[current_player;craft;1.75,0.5;3,3;]"..
        "listring[current_player;craft]"..
        "list[detached:tai_trash;main;0.8,1.5;1,1;]"..
        "list[current_player;craftpreview;5.75,1.5;1,1;]"..
        "image[4.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]"
end

tai.gui_craftequip = function(cfg)
    local formspec = {}
    local stats = armor.def[cfg.player_name];

    if armor and armor.def then
        formspec[#formspec+1] = 'list[detached:'..cfg.player_name..'_armor;armor;0,0.25;1,4;]'
        formspec[#formspec+1] = 'list[detached:'..cfg.player_name..'_armor;armor;1,3.25;2,1;4]'
        formspec[#formspec+1] = 'image[1.22,0.35;1.7,3.2;'..armor.textures[cfg.player_name].preview..']'
    end

    formspec[#formspec+1] = 'image[3,3.25;0.4,0.4;tai_chestplate.png]'
    formspec[#formspec+1] = 'label[3.4,3.20;'..stats.level..']'
    formspec[#formspec+1] = 'image[3,3.75;0.4,0.4;tai_heart.png]'
    formspec[#formspec+1] = 'label[3.4,3.70;'..stats.heal..']'

    formspec[#formspec+1] = 'image[4,3.25;0.4,0.4;tai_rad.png]'
    formspec[#formspec+1] = 'label[4.4,3.20;'..stats.radiation..']'

    formspec[#formspec+1] = 'image[5,3.25;0.4,0.4;tai_fire.png]'
    formspec[#formspec+1] = 'label[5.4,3.20;'..stats.water..']'
    formspec[#formspec+1] = 'image[5,3.75;0.4,0.4;tai_water.png]'
    formspec[#formspec+1] = 'label[5.4,3.70;'..stats.fire..']'

    formspec[#formspec+1] = "list[current_player;craft;3,0.25;3,3;]"..
        "listring[current_player;craft]"..
        "list[detached:tai_trash;main;7,3.25;1,1;]"..
        "list[current_player;craftpreview;6,1.25;1,1;]"
    return table.concat(formspec, '')
end

tai.gui_mods = function(cfg)
    local formspec = {'textlist[8,0;3,8.8;tai_mod;'}
    table.insert(formspec,table.concat(tai.modnames, ","))
    table.insert(formspec,';'..cfg.category..';true]')
    return table.concat(formspec, "")
end

tai.gui_items = function(cfg)
    local creative_list = {}
    local dx, dy = 0.83, 0.9
    local x, y = 0, 0
    local w, h = 0.9, 0.85
    local total = cfg.cols * cfg.rows
    local index = 1
    local maxpages = 0
    local formspec = {}
    local def = {}

    local itemname = ''
    local itemcaption = ''

    for i, name in ipairs(tai.itemlist) do
        def = minetest.registered_items[name]
        if def.name:find(cfg.filter, 1, true) or def.description:lower():find(cfg.filter, 1, true) then
            creative_list[#creative_list + 1] = name
        end
    end

    table.sort(creative_list)

    if cfg.page < 0 then
        cfg.page = 0
    end

    maxpages = math.floor(#creative_list/total)
    if #creative_list % total == 0 then
        maxpages = maxpages - 1
    end
    if cfg.page >= maxpages then
        cfg.page = maxpages
    end

    index = total * cfg.page

    for i=1,total do
        if creative_list[index + i] then
            itemname = creative_list[index + i]
            def = minetest.registered_items[creative_list[index + i]]
            if def.description and def.description ~= '' then
                itemcaption = def.description..minetest.formspec_escape(' ['..itemname:sub(1, itemname:find(':', 1, true)-1)..']')
            else
                itemcaption = minetest.formspec_escape('['..itemname..']')
            end
            formspec[#formspec + 1] = 'image_button['..x..','..y..';'..w..','..h..';tai_slot.png;tai_give:'..itemname..';;false;false;tai_slot_active.png]'
            formspec[#formspec + 1] = 'item_image['..tostring(x+0.1)..','..tostring(y+0.1)..';'..tostring(w-0.3)..','..tostring(h-0.3)..';'..itemname..']'
            formspec[#formspec + 1] = 'tooltip[tai_give:'..itemname..';'..itemcaption..']'
            x = x + dx
            if i%cfg.cols == 0 then
                x = 0
                y = y + dy
            end
        end
    end

    if #creative_list > total then
        formspec[#formspec + 1] = 'image_button[5.81,'..tostring(dy*cfg.rows)..';0.9,0.85;tai_slot.png;tai_prev;<<;false;false;tai_slot_active.png]'
        formspec[#formspec+1] = 'tooltip[tai_prev;Previous page]'
        formspec[#formspec + 1] = 'image_button[6.64,'..tostring(dy*cfg.rows)..';0.9,0.85;tai_slot.png;tai_next;>>;false;false;tai_slot_active.png]'
        formspec[#formspec+1] = 'tooltip[tai_next;Next Page]'
        formspec[#formspec + 1] = 'label[4.5,'..tostring(dy*cfg.rows+0.2)..';'..tostring(cfg.page+1)..'/'..tostring(maxpages+1)..']'
    end

    return table.concat(formspec, "")
end

tai.gui_search = function(cfg)
    local formspec = {}
    formspec[#formspec + 1] = 'field[0.3,'..tostring(0.9*cfg.rows+0.27)..';3.36,1;tai_search;;'..minetest.formspec_escape(cfg.filter)..']'
    formspec[#formspec + 1] = 'image_button[3.32.64,'..tostring(0.9*cfg.rows)..';0.9,0.85;tai_slot.png;tai_resetsearch;X;false;false;tai_slot_active.png]'
    formspec[#formspec + 1] = 'tooltip[tai_resetsearch;Reset search]'
    formspec[#formspec + 1] = 'field_close_on_enter[tai_search;false]'
    return table.concat(formspec, "")
end

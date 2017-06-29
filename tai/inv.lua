local inv = {}
tai.inv = inv

inv.tabs = {}
inv.main = function(cfg)
    local formspec = {}
    local colors = {
        cfg.slot_bg,
        cfg.slot_bg_hover,
        cfg.slot_border,
        cfg.tooltip_bg,
        cfg.tooltip
    }
    formspec[#formspec+1] = 'size[8,8.6]'
    formspec[#formspec+1] = 'bgcolor['..cfg.bgcolor..';false]'
    formspec[#formspec+1] = 'listcolors['..table.concat(colors, ";")..']'
    return table.concat(formspec, "")
end

inv.pages = function(cfg)
    local formspec = 'tabheader[0,0;tai_tab;'..table.concat(inv.tabs, ',')..';'..cfg.tab..';true;false]'
    return formspec
end

inv.player = function()
    return "list[current_player;main;0,4.75;8,1;]"..
    "list[current_player;main;0,5.9;8,3;8]"..
    "listring[current_player;main]"
end

inv.craft = function()
    return "list[current_player;craft;1.75,0.5;3,3;]"..
        "listring[current_player;craft]"..
        "list[detached:tai_trash;main;0.8,1.5;1,1;]"..
        "list[current_player;craftpreview;5.75,1.5;1,1;]"..
        "image[4.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]"
end

inv.mods = function(cfg)
    local formspec = { 'tableoptions[background=#282C34FF;border=false;highlight=#4D78CCFF]' }
    formspec[#formspec + 1] = 'table[0,0;7.8,7.8;tai_mod;'..table.concat(tai.mods, ",")..';'..cfg.category..']'
    formspec[#formspec + 1] = tai.inv_button_big('tai_modcancel', 0.3, 9, 'Cancel')
    formspec[#formspec + 1] = tai.inv_button_big('tai_modsearch', 5.2, 9, 'OK')
    return table.concat(formspec, '')
end

inv.items = function(cfg)
    local creative_list = {}
    local total = 40
    local index = 1
    local maxpages = 0
    local formspec = {}
    local def = {}

    for i, name in ipairs(tai.items) do
        def = minetest.registered_items[name]
        if def.name:find(cfg.filter, 1, true) or def.description:lower():find(cfg.filter, 1, true) then
            creative_list[#creative_list + 1] = name
        end
    end

    table.sort(creative_list)

    maxpages = math.floor(#creative_list/total)
    if #creative_list % total == 0 then
        maxpages = maxpages - 1
    end

    if cfg.page < 0 then
        cfg.page = maxpages
    end

    if cfg.page > maxpages then
        cfg.page = 0
    end

    index = total * cfg.page

    formspec[#formspec + 1] = tai.inv_items_list(creative_list, {
        index = 40 * cfg.page + 1,
        length = index + 40,
        x = 0,
        y = 0,
        cols = 10,
        empty = false
    })

    local pos = tai.inv_coords({x=6, y=4})
    --search field
    formspec[#formspec + 1] = 'field[0.3,'..tostring(pos.y + 0.27)..';3.3,1;tai_search;;'..minetest.formspec_escape(cfg.filter)..']'
    formspec[#formspec + 1] = tai.inv_button('tai_resetsearch', 4, 4, 'X')
    formspec[#formspec + 1] = tai.inv_button('tai_showmods', 5, 4, '?')
    formspec[#formspec + 1] = 'tooltip[tai_resetsearch;Reset search]'
    formspec[#formspec + 1] = 'tooltip[tai_showmods;Mod list]'
    formspec[#formspec + 1] = 'field_close_on_enter[tai_search;false]'
    --prev/next
    if #creative_list > total then
        formspec[#formspec + 1] = 'label['..tostring(pos.x + 0.2)..','..tostring(pos.y + 0.2)..';'..tostring(cfg.page + 1)..'/'..tostring(maxpages + 1)..']'
        formspec[#formspec + 1] = tai.inv_button('tai_prev', 8, 4, '<<')
        formspec[#formspec + 1] = tai.inv_button('tai_next', 9, 4, '>>')
        formspec[#formspec+1] = 'tooltip[tai_prev;Previous page]'
        formspec[#formspec+1] = 'tooltip[tai_next;Next Page]'
    end

    return table.concat(formspec, "")
end

inv.recipe = function (cfg)
    local formspec = {}
    local craft_item = cfg.recipe.item
    local recipes, craft_type
    local type_index, recipe_index = cfg.recipe.typeindex,  cfg.recipe.index
    local pos
    if type_index < 1 then
        type_index = #tai.craft_recipe[craft_item]
    end
    if type_index > #tai.craft_recipe[craft_item] then
        type_index = 1
    end
    cfg.recipe.typeindex = type_index
    recipes = tai.craft_recipe[craft_item][type_index].recipes
    craft_type = tai.craft_recipe[craft_item][type_index].craft_type
    if recipe_index < 1 then
        recipe_index = #recipes
    end
    if recipe_index > #recipes then
        recipe_index = 1
    end
    cfg.recipe.index = recipe_index
    formspec[#formspec + 1] = tai.inv_button('tai_recipe_hide', 9, 0, 'X')
    formspec[#formspec + 1] = tai.inv_button('tai_crafttype_next', 8, 0, '>>')
    formspec[#formspec + 1] = tai.inv_button('tai_crafttype_prev', 0, 0, '<<')
    formspec[#formspec + 1] = 'label[3,0.15;'..tai.craft_type[craft_type].caption..']'

    formspec[#formspec + 1] = tai.inv_button('tai_craft_next', 9, 1, '>>')
    formspec[#formspec + 1] = tai.inv_button('tai_craft_prev', 8, 1, '<<')
    pos = tai.inv_coords({x = 4, y = 1.1})
    formspec[#formspec + 1] = 'label['..pos.x..','..pos.y..';'..recipe_index..'/'..#recipes..']'

    formspec[#formspec + 1] = 'box[0,'..tostring(pos.y - 0.07)..';6.2,0.7;'..tai.config.slot_border..']'
    formspec[#formspec + 1] = tai.craft_type[craft_type].formspec(recipes[recipe_index])
    formspec[#formspec + 1] = 'box[0,6.3;7.8,0.7;'..tai.config.slot_border..']'
    formspec[#formspec + 1] = 'label[0.4,6.4;'..ItemStack(craft_item):get_definition().description..' ('..core.colorize('#00FF00', ItemStack(craft_item):get_name())..')]'
    if minetest.check_player_privs(cfg.player_name, {creative = true}) then
        formspec[#formspec + 1] = tai.inv_item_button('tai_give:'..craft_item, 9, 2, craft_item)
        formspec[#formspec + 1] = 'tooltip[tai_give:'..craft_item..';Take]'
    end
    return table.concat(formspec, "")
end

inv.settings = function (cfg)
    local formspec = {}
    if cfg.recipe.enabled then
        formspec[#formspec + 1] = tai.inv_button_big('tai_setting_recipe', 0, 0, 'Recipe: On')
    else
        formspec[#formspec + 1] = tai.inv_button_big('tai_setting_recipe', 0, 0, 'Recipe: Off')
    end
    if minetest.check_player_privs(cfg.player_name, {creative = true}) then
        formspec[#formspec + 1] = tai.inv_button_big('tai_setting_creative', 0, 1, 'Creative: On')
    else
        formspec[#formspec + 1] = tai.inv_button_big('tai_setting_creative', 0, 1, 'Creative: Off')
    end
    return table.concat(formspec, '')
end

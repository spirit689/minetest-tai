tai.inv.recipe = function (cfg)
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

    return table.concat(formspec, "")
end

local function inv_crafting(recipe)
    local n, dx, dy, pos
    local formspec = {}
    local items = {}
    local output = ItemStack(recipe.output)
    local width = recipe.width
    local recipe_width = recipe.width
    if recipe.width == 0 then
        n = 0
        for _ , item in ipairs(recipe.items) do
            n = n + 1
        end
        width = math.ceil(math.sqrt(n))
        recipe_width = width
    else
        width = recipe.width
        recipe_width = recipe.width
    end
    if width < 3 then
        width = 3
    end
    n = 0
    for i = 1, width do
        for j = 1, recipe_width do
            n = n + 1
            items[3 * (i - 1) + j] = recipe.items[n]
        end
    end
    dx = 5 - (width + 2) / 2
    dy = 4.5 - width / 2 -- ( 2.7(3rd row) + 6.3(dark line) ) / 2
    formspec[#formspec + 1] = tai.inv_items_list(items, {x = dx, y = dy, length = math.pow(width, 2), cols = width})
    pos = tai.inv_coords({x = dx + width, y = dy + width / 2 - 0.3})
    formspec[#formspec + 1] = 'image['..pos.x..','..pos.y..';1,0.5;tai_arrow.png]'
    formspec[#formspec + 1] = tai.inv_items_list({ output:get_name() }, {x = dx + width + 1, y = dy + width / 2 - 0.5, length = 1, cols = 1})
    if output:get_count() > 1 then
        pos = tai.inv_coords({x = dx + width + 2, y = dy + width / 2})
        formspec[#formspec + 1] = 'label['..pos.x..','..pos.y..';'..output:get_count()..']'
    end
    return table.concat(formspec,'')
end

tai.register_craft_type('normal', 'Normal', inv_crafting)
tai.register_craft_type('shapeless', 'Shapeless', inv_crafting)

tai.register_craft_type('cooking', 'Cooking', function (recipe)
    local formspec = {}
    local output = ItemStack(recipe.output)

    formspec[#formspec + 1] = tai.inv_items_list(recipe.items, {x = 3, y = 4, length = 1, cols = 1})
    pos = tai.inv_coords({x = 4, y = 4.2})
    formspec[#formspec + 1] = 'image['..pos.x..','..pos.y..';1,0.5;tai_arrow.png]'
    formspec[#formspec + 1] = tai.inv_items_list({ output:get_name() }, {x = 5, y = 4, length = 1, cols = 1})

    if output:get_count() > 1 then
        pos = tai.inv_coords({x = 6, y = 4.5})
        formspec[#formspec + 1] = 'label['..pos.x..','..pos.y..';'..output:get_count()..']'
    end

    return table.concat(formspec,'')
end)

-- navigation
tai.add_action('tai_crafttype_next', function (cfg, player, fields)
    cfg.recipe.typeindex = cfg.recipe.typeindex + 1
    cfg.recipe.index = 1
end)

tai.add_action('tai_crafttype_prev', function (cfg, player, fields)
    cfg.recipe.typeindex = cfg.recipe.typeindex - 1
    cfg.recipe.index = 1
end)

tai.add_action('tai_craft_next', function (cfg, player, fields)
    cfg.recipe.index = cfg.recipe.index + 1
end)

tai.add_action('tai_craft_prev', function (cfg, player, fields)
    cfg.recipe.index = cfg.recipe.index - 1
end)

tai.add_action('tai_recipe_hide', function (cfg, player, fields)
    cfg.formspec.player = 1
    cfg.formspec.items = 1
    cfg.formspec.recipe = 0
    cfg.recipe.show = 0
end)

tai.add_action('tai_item', function (cfg, player, fields)
    if minetest.check_player_privs(player, {creative = true}) then
        return
    end
    local craft_item = fields.item
    if tai.craft_recipe[craft_item] then
        cfg.formspec.player = 0
        cfg.formspec.items = 0
        cfg.formspec.recipe = 1
        cfg.recipe.show = 1
        cfg.recipe.item = craft_item
    end
end)

tai.add_action('tai_tab', function (cfg, player, fields)
    if cfg.tab == 2 then
        if cfg.recipe.show == 1 then
            cfg.formspec.recipe = 1
            cfg.formspec.items = 0
            cfg.formspec.player = 0
        end
    end
end)

tai.add_action('init_player', function (cfg)
    cfg.recipe = {
        typeindex = 1,
        index = 1
    }
end)

tai.add_action('init', function (cfg)
    local i = 0
    local t1
    local recipes
    local items, group
    t1 = os.clock()
    -- load recipes
    for i,name in ipairs(tai.items) do
        recipes = minetest.get_all_craft_recipes(name)
    	if recipes then
    		for i, recipe in ipairs(recipes) do
    			if (recipe and recipe.items and recipe.type) then
    				tai.register_craft(name, recipe)
    			end
    		end
    	end
    end
    -- print(dump(tai.groups))
    print("[TAI] All recipes loaded in "..os.clock() - t1)
    -- override some group items
    tai.groups.wood = "default:wood"
    tai.groups.stone = "default:cobble"
    tai.groups.sand = "default:sand"
    tai.groups.leaves = "default:leaves"
    tai.groups.tree = "default:tree"
    tai.groups.wool = "wool:white"
end)

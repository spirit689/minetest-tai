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
    formspec[#formspec + 1] = tai.inv_items_list(items, {x = dx, y = dy, length = math.pow(width, 2), cols = width, empty = true})
    pos = tai.inv_coords({x = dx + width, y = dy + width / 2 - 0.3})
    formspec[#formspec + 1] = 'image['..pos.x..','..pos.y..';1,0.5;tai_arrow.png]'
    formspec[#formspec + 1] = tai.inv_items_list({ output:get_name() }, {x = dx + width + 1, y = dy + width / 2 - 0.5, length = 1, cols = 1})
    if output:get_count() > 1 then
        pos = tai.inv_coords({x = dx + width + 2, y = dy + width / 2})
        formspec[#formspec + 1] = 'label['..pos.x..','..pos.y..';'..output:get_count()..']'
    end
    return table.concat(formspec,'')
end

tai.register_craft_type('normal', {caption = 'Normal', icon = 'default_tool_diamondpick.png'}, inv_crafting)
tai.register_craft_type('shapeless', {caption = 'Shapeless', icon = '[inventorycube{default_chest_top.png{default_chest_front.png{default_chest_side.png'}, inv_crafting)

tai.register_craft_type('cooking', {caption = 'Cooking', icon = '[inventorycube{default_furnace_top.png{default_furnace_front.png{default_furnace_side.png'}, function (recipe)
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
tai.add_action('tai_crafttype', function (cfg, player, fields)
    cfg.recipe.index = 1
    cfg.recipe.typeindex = tonumber(fields.typeindex)
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
    cfg.recipe.show = false
    cfg.recipe.item = ''
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

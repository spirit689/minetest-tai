
tai.register_craft = function (itemname, recipe, recipe_type)
    local craft_type
    local k = 0
    local index = 1
    local add_index = 1

    -- try to get recipe type: normal, shapeless, cooking, etc
    if recipe_type and recipe_type ~= '' then
        craft_type = recipe_type
    else
        if recipe.type ~= '' then
            craft_type = recipe.type
        end
        if craft_type == 'normal' and recipe.width == 0 then
            craft_type = 'shapeless'
        end
    end
    -- add craft tai.craft_recipe[index] = { craft_type = craft_type, recipes = {...} }
    if tai.craft_type[craft_type] then
        if type(tai.craft_recipe[itemname]) ~= 'table' then
            tai.craft_recipe[itemname] = {}
        end
        for i, def in ipairs(tai.craft_recipe[itemname]) do
            if def.craft_type == craft_type then
                k = 1
                index = i
                break
            end
        end
        -- check and insert accordingly register order
        if k == 0 then
            add_index = #tai.craft_recipe[itemname] + 1
            if #tai.craft_recipe[itemname] > 0 then
                if tai.get_craft_type_order(craft_type) < tai.get_craft_type_order(tai.craft_recipe[itemname][1].craft_type) then
                    add_index = 1
                end
            end
            table.insert(tai.craft_recipe[itemname], add_index, {
                craft_type = craft_type,
                recipes = { recipe }
            })
        else
            table.insert(tai.craft_recipe[itemname][index].recipes, recipe)
        end
    end
end

tai.register_craft_type = function (craft_type, def, formspec)
    tai.craft_type[craft_type] = {
        caption = def.caption,
        icon = def.icon,
        formspec = formspec
    }
end

tai.get_craft_type_order = function (craft_type)
    local order = 1
    for _type, def in pairs(tai.craft_type) do
        if _type == craft_type then
            break
        end
        order = order + 1
    end
    return order
end

-- recipe formspec
local function inv_technic (recipe)
    local output = {}
    local formspec = {}
    local n = 0

    local pos = tai.inv_coords({x = 4, y = 4.2})
    formspec[#formspec + 1] = 'image['..pos.x..','..pos.y..';1,0.5;tai_arrow.png]'
    formspec[#formspec + 1] = 'label['..pos.x..','..tostring(pos.y + 1)..';Time: '..recipe.time..'s]'

    for itemname, count in pairs(recipe.input) do
        n = n + 1
    end
    for itemname, count in pairs(recipe.input) do
        formspec[#formspec + 1] = tai.inv_item_button('tai_item:'..itemname, 4 - n * 1.3, 4, itemname)
        pos = tai.inv_coords({x = 5 - n * 1.3, y = 4.5})
        formspec[#formspec + 1] = 'label['..pos.x..','..pos.y..';'..count..']'
        n = n - 1
    end

    if type(recipe.output) == "table" then
        output = recipe.output
    elseif type(recipe.output) == "string" then
        output = {
            recipe.output
        }
    end

    for i, item in pairs(output) do
        formspec[#formspec + 1] = tai.inv_item_button('tai_item:'..ItemStack(item):get_name(), 4 + i * 1.3, 4, ItemStack(item):get_name())
        pos = tai.inv_coords({x = 5 + i * 1.3, y = 4.5})
        formspec[#formspec + 1] = 'label['..pos.x..','..pos.y..';'..ItemStack(item):get_count()..']'
    end

    print(dump(technic.recipes))
    return table.concat(formspec, '')
end

local machines = {
    {'alloy', 'mv_alloy_furnace', 'Alloy Furnace'},
    {'separating', 'mv_centrifuge', 'Centrifuge'},
    {'compressing', 'mv_compressor', 'Compressor'},
    {'extracting', 'mv_extractor', 'Extractor'},
    {'grinding', 'mv_grinder', 'Grinder'}
}

for i, data in ipairs(machines) do
    tai.register_craft_type('technic:'..data[1], {
        caption = data[3],
        icon = '[inventorycube{technic_'..data[2]..'_top.png{technic_'..data[2]..'_side.png{technic_'..data[2]..'_front.png'},
    inv_technic)
end

-- register
minetest.after(10, function (args)
    local itemname, recipe, output
    for craft_type, data in pairs(technic.recipes) do
        if data.recipes then
            for items, def in pairs(data.recipes) do
                if type(def.output) == "table" then
                    output = def.output
                elseif type(def.output) == "string" then
                    output = {
                        def.output
                    }
                end
                for i, item in ipairs(output) do
                    itemname = ItemStack(item):get_name()
                    tai.register_craft(itemname, def, 'technic:'..craft_type)
                end
            end
        end
    end
end)

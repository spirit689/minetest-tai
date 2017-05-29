tai.give_item = function (player, item)
    local player_name = player:get_player_name()
    local inventory = player:get_inventory()
    local s = ItemStack(item)
    inventory:add_item("main", {name = item, count = s:get_stack_max()})
end

tai.is_allowed_item = function(name)
    local l = tai.config.whitelist
    for _,v in ipairs(l) do
        if name:find(v, 1, true) then
            return true
        end
    end
    return false
end

tai.inv_button = function (id, x, y, caption)
    local dx, dy = 0.792, 0.9
    return 'image_button['..tostring(x * dx)..','..tostring(y * dy)..';0.9,0.85;tai_slot.png;'..id..';'..minetest.formspec_escape(caption)..';false;false;tai_slot_active.png]'
end

tai.inv_button_big = function (id, x, y, caption)
    local dx, dy = 0.792, 0.9
    return 'image_button['..tostring(x * dx)..','..tostring(y * dy)..';3.6,0.85;tai_button.png;'..id..';'..minetest.formspec_escape(caption)..';false;false;tai_button_active.png]'
end

-- return small grid (10x9) coords
tai.inv_coords = function (args)
    local dx, dy = 0.792, 0.9
    local maxx, maxy = 9, 8
    local coords = {}
    if args.x then
        coords.x = dx * args.x
    end
    if args.y then
        coords.y = dy * args.y
    end
    return coords
end

tai.inv_items_list = function (items, args)
    local dx, dy = 0.792, 0.9
    local w, h = 0.9, 0.85
    local cols = args.cols
    local index, l
    local x, y = args.x * dx, args.y * dy
    local startx = x
    local itemname, itemcaption, def, groups
    local formspec = {}

    if args.index then
        index = args.index
    else
        index = 1
    end

    if args.length then
        l = args.length
    else
        l = #items
    end

    for i=index,l do
        itemname = items[i]
        if itemname and itemname ~= '' then
            if itemname:find('group:', 1, true) then
                itemcaption = minetest.formspec_escape(core.colorize('#00FF00', string.gsub(itemname, ',', '\ngroup:')))
                groups = itemname:sub(itemname:find(':', 1, true)+1):split(',')
                formspec[#formspec + 1] = 'item_image['..tostring(x + 0.1)..','..tostring(y + 0.1)..';'..tostring(w - 0.27)..','..tostring(h - 0.25)..';'..tai.groups[groups[1]]..']'
            else
                def = minetest.registered_items[itemname]
                if def.description and def.description ~= '' then
                    itemcaption = minetest.formspec_escape(def.description..'\n'..core.colorize('#00FF00',itemname))
                end
                formspec[#formspec + 1] = 'item_image['..tostring(x + 0.1)..','..tostring(y + 0.1)..';'..tostring(w - 0.27)..','..tostring(h - 0.25)..';'..itemname..']'
            end
            formspec[#formspec + 1] = 'image_button['..x..','..y..';'..w..','..h..';tai_slot.png;tai_item:'..itemname..';;false;false;tai_slot_active.png]'
            formspec[#formspec + 1] = 'tooltip[tai_item:'..itemname..';'..itemcaption..']'
        else
            formspec[#formspec + 1] = 'image['..x..','..y..';'..w..','..h..';tai_slot.png]'
        end
        x = x + dx
        if i % cols == 0 then
            x = startx
            y = y + dy
        end
    end

    return table.concat(formspec, '')
end

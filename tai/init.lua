tai = {}
tai.config = {}
tai.player_config = {}
tai.mods = {}
tai.items = {}
tai.groups = {}
tai.tabs = {}
tai.callbacks = {}
tai.craft_type = {}
tai.craft_recipe = {}

local path = minetest.get_modpath(minetest.get_current_modname())
dofile(path..'/api.lua')
dofile(path..'/api_item.lua')
dofile(path..'/api_recipe.lua')
dofile(path..'/inv.lua')
dofile(path..'/main.lua')
dofile(path..'/recipe.lua')
if minetest.get_modpath('technic') then
    dofile(path..'/recipe_technic.lua')
end

tai.config.delay = tai.settings:get('tai_delay_time', 5)
tai.config.whitelist = tai.settings:get('tai_filters', ''):split(',')
tai.config.bgcolor = tai.settings:get('tai_bgcolor', '#21252BFF')
tai.config.slot_bg = tai.settings:get('tai_slot_bg', '#282C34FF')
tai.config.slot_bg_hover = tai.settings:get('tai_slot_bg_hover', '#2C323CFF')
tai.config.slot_border = tai.settings:get('tai_slot_border', '#181A1FFF')
tai.config.tooltip = tai.settings:get('tai_tooltip', '#FFFFFFFF')
tai.config.tooltip_bg = tai.settings:get('tai_tooltip_bg', '#66666666')

local trash = minetest.create_detached_inventory("tai_trash", {
	allow_put = function(inv, listname, index, stack, player)
		return stack:get_count()
	end,
	on_put = function(inv, listname)
		inv:set_list(listname, {})
	end,
})
trash:set_size("main", 1)

minetest.register_privilege("creative", {
	description = "Can use the creative inventory",
	give_to_singleplayer = false
})

minetest.register_on_joinplayer(function(player)
    minetest.after(tai.config.delay, function()
        local name = player:get_player_name()
        local privs = minetest.get_player_privs(name)
        if minetest.check_player_privs(player, {creative = true}) or minetest.settings:get_bool("creative_mode") then
            privs.creative = true
        end
        minetest.set_player_privs(name, privs)
        minetest.chat_send_player(player:get_player_name(), "TAI: Initialized")
        tai.init_player(name)
        tai.do_action('init_player', tai.player_config[name], player, {})
        player:set_inventory_formspec(tai.build_formspec(player:get_player_name()))
    end)
end)

minetest.register_on_leaveplayer(function(player)
    tai.settings:save_data(player:get_player_name())
    tai.player_config[player_name] = nil
end)

minetest.register_on_shutdown(function()
    for player_name, def in pairs(tai.player_config) do
        tai.settings:save_data(player_name)
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    local cfg = tai.player_config[name]
    local evt = {}
    if fields['quit'] then return end
    tai.do_action('receive_fields', cfg, player, fields)
    for field,val in pairs(fields) do
        if tai.callbacks[field] then
            for _,cb in ipairs(tai.callbacks[field]) do
                cb(cfg, player, fields)
            end
        end
    end
    player:set_inventory_formspec(tai.build_formspec(name))
end)

minetest.after(0, tai.init)

local xray = require('__Tree_XRay__.scripts.xray')

storage.moving_player = nil
if not storage.players_xray then return end

xray.init()
xray.setup()

for player_id, player_storage in pairs(storage.players_xray) do
	local player = game.get_player(player_id)
	if player then
		storage.xray_sources[player_id] = {}
		for _, tree in pairs(player_storage) do
			xray.add_xray_source(tree, player_id, player)
		end
	end
end

storage.players_xray = nil

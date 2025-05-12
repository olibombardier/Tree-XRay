storage.moving_player = nil
if not storage.players_xray then return end

storage.xrayed_trees = storage.xrayed_trees or {}
local xrayed_trees = storage.xrayed_trees
storage.xray_sources = storage.xray_sources or {}

for player_id, player_storage in pairs(storage.players_xray) do
	local player = game.get_player(player_id)
	if player then
		storage.xray_sources[player_id] = {}
		for _, tree in pairs(player_storage) do
			if tree.valid then
				xrayed_trees[tree] = xrayed_trees[tree] or {}
				xrayed_trees[tree][player_id] = game.tick

				storage.xray_sources[player_id][tree] = game.tick
			end
		end
	end
end

storage.players_xray = nil

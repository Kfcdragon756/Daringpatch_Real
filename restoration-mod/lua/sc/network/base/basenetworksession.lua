BaseNetworkSession.CONNECTION_TIMEOUT = 30 --not sure, 10 by default.
BaseNetworkSession.LOADING_CONNECTION_TIMEOUT = SystemInfo:platform() == Idstring("WIN32") and 60 or 60 --what is this? 20 by default.
BaseNetworkSession._LOAD_WAIT_TIME = 15 -- this is 3 by default.  suspicion this is our package culprit, so i've increased it slightly to 15s for testing over the next couple of days.  increase it again if results aren't noticed

Hooks:PostHook(BaseNetworkSession,"on_peer_sync_complete","resmod_send_sync_env_data",function(self,peer,peer_id)
	if not self._local_peer then
		return
	end

	if not peer:ip_verified() then
		return
	end
	Hooks:Call("restoration_on_synced_peer",peer,peer_id)
end)

-- Integrated host sequence authority. Uses the existing overhaul hook registration.
do
 local authority = rawget(_G, "RestorationSequenceAuthority")
 if not authority then
  local root = restoration and restoration._mod_path
  if not root then
   local source = debug.getinfo(1, "S").source:gsub("^@", ""):gsub("\\", "/")
   root = source:match("^(.-)/lua/")
  end
  assert(root, "[SequenceAuthority] Cannot resolve overhaul root")
  -- The game loader need not propagate the Lua chunk return value.
  dofile(root:gsub("[/\\]+$", "") .. "/lua/sc/core/sequence_authority.lua")
  authority = rawget(_G, "RestorationSequenceAuthority")
 end
 assert(type(authority) == "table" and type(authority.install) == "function",
  "[SequenceAuthority] sequence_authority.lua did not initialize; verify the complete integrated lua folder is installed")
 authority:install()
end -- Restoration authority bootstrap




Hooks:PostHook(BaseNetworkSession, "on_peer_entered_lobby", "Daring_is_pro_fixed_sync", function(self, peer)
	local peer_id = peer and peer:id()
	local is_pro = Global.game_settings and Global.game_settings.one_down
	if is_pro then
		log("is_pro checked")
	end
	local pro_message = {
		is_pro = 'nil',
		session = "NoSession"
	}
	if Network:is_server() then
		pro_message.session = 'host'
		if is_pro then
			pro_message.is_pro = 'true'
		end
	elseif Network:is_client() then
		return
	end
	if peer_id then LuaNetworking:SendToPeer(peer_id, 'Resmod_Daring_is_pro_fixed_sync', json.encode(pro_message)) end
end)

--[[---------------------------------------------------------
	(Made for Toribash 5.7x)
	  RTK 1.1: Replaymaking Toolkit by miso903

	COMMANDS:
		/skip			: Cache replay to get speed controls
		/ff	<number>	: Fast forward to specified number
		/qe				: Quick edit rewinds 100 frames earlier
		/fov <number>	: Change FOV to specified number

	BINDS:
		Shift + R		: /skip
		N				: /ff (last number)
		Shift + N		: Go back a turn (your set tf)
		Ctrl/Alt + Q	: /qe

	"damn"
	"it's actually so op"
	"unironically i'll use it lol"
	  — jagger700
-----------------------------------------------------------]]

local _sub = string.sub
local ffFrame = 0
local winScreenFrames = 101

local function spamShiftP(frames) -- Shift + P at light speed
	for i = 1, frames do
		toggle_game_pause(true)
	end
end

local function skipReplay(ff, qe)
	local mf = get_game_rules().matchframes + winScreenFrames
	local remainingFrames = mf

	if get_world_state().replay_mode == 0 then -- Must rewind if still editing
		rewind_replay()
	else
		remainingFrames = (mf - get_world_state().match_frame)
	end

	spamShiftP(remainingFrames)

	if ff then
		local f = qe or ffFrame
		rewind_replay_to_frame(f)
	end
end

local function skipCommand(cmd)
	if cmd == "skip" then
		skipReplay()
		return 1
	end
end
add_hook("command", "skipCommand", skipCommand)

local rKey = 114
local function skipBind(key)
	if key == rKey and get_keyboard_shift() > 0 then
		if get_replay_cache() == 0 then
			skipReplay()
		end
	end
end
add_hook("key_up", "skipBind", skipBind)

local function fastForward()
	if ffFrame == 0 or ffFrame == get_game_rules().matchframes then return end

	if get_replay_cache() == 0 then
		skipReplay(true)
	else
		rewind_replay_to_frame(ffFrame)
	end
end

local function ffCommand(cmd)
	if _sub(cmd, 1, 2) == "ff" then
		local mf = get_game_rules().matchframes
		local ff = tonumber(_sub(cmd, 4, 8)) -- string.explode require(toriui.uielement), this works
		ffFrame = (ff and mf - ff) or ffFrame

		fastForward()
		echo("/ff " .. mf - ffFrame)
		return 1
	end
end
add_hook("command", "ffCommand", ffCommand)

local nKey = 110
local function ffBind(key)
	if key == nKey and get_keyboard_shift() == 0 then
		fastForward()
	end
end
add_hook("key_up", "ffBind", ffBind)

local function quickEdit(qe)
	local f = get_world_state().match_frame
	local tf = tonumber(get_game_rules().turnframes)
	local qeFrame = (qe and f - 100) or (f - tf - f % tf)

	if get_replay_cache() == 1 then
		rewind_replay_to_frame(qeFrame)
		if not is_game_paused() then toggle_game_pause() end
		return
	end

	if qe then
		skipReplay(true, qeFrame) -- Cache replay here
		return
	end

	rewind_replay()
	spamShiftP(qeFrame) -- Don't cache replay for quicker 1st rewind
end

local function qeCommand(cmd)
	if cmd == "qe" then
		quickEdit(true)
		return 1
	end
end
add_hook("command", "qeCommand", qeCommand)

local qKey = 113
local function qeBind(key)
	if key == nKey and get_keyboard_shift() > 0 then
		quickEdit()
	elseif key == qKey and get_keyboard_ctrl() > 0 or get_keyboard_alt() > 0 then
		quickEdit(true)
	end
end
add_hook("key_up", "qeBind", qeBind)

local function setFov(cmd)
	if _sub(cmd, 1, 3) == "fov" then
		local fov = tonumber(_sub(cmd, 5, 7)) or 50
		set_fov(fov)

		if fov == 50 then
			echo("/fov 50 (default)")
		else
			echo("/fov " .. fov)
		end
		return 1
	end
end
add_hook("command", "setFov", setFov)

echo("rtk.lua")

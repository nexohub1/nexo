repeat task.wait() until game:IsLoaded()
if shared.nexo then shared.nexo:Uninject() end

-- why do exploits fail to implement anything correctly? Is it really that hard?
if identifyexecutor then
	if table.find({'Argon', 'Wave'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local nexo
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and nexo then
		nexo:CreateNotification('Nexo', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/nexohub1/nexo/'..readfile('nexo/profiles/commit.txt')..'/'..select(1, path:gsub('nexo/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after nexo updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	nexo.Init = nil
	nexo:Load()
	task.spawn(function()
		repeat
			nexo:Save()
			task.wait(10)
		until not nexo.Loaded
	end)

	local teleportedServers
	nexo:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.nexoIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.nexoreload = true
				if shared.nexoDeveloper then
					loadstring(readfile('nexo/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/nexohub1/nexo/'..readfile('nexo/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.nexoDeveloper then
				teleportScript = 'shared.nexoDeveloper = true\n'..teleportScript
			end
			if shared.nexoCustomProfile then
				teleportScript = 'shared.nexoCustomProfile = "'..shared.nexoCustomProfile..'"\n'..teleportScript
			end
			nexo:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.nexoreload then
		if not nexo.Categories then return end
		if nexo.Categories.Main.Options['GUI bind indicator'].Enabled then
			nexo:CreateNotification('Finished Loading', nexo.nexoButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(nexo.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('nexo/profiles/gui.txt') then
	writefile('nexo/profiles/gui.txt', 'new')
end
local gui = readfile('nexo/profiles/gui.txt')

if not isfolder('nexo/assets/'..gui) then
	makefolder('nexo/assets/'..gui)
end
nexo = loadstring(downloadFile('nexo/guis/'..gui..'.lua'), 'gui')()
shared.nexo = nexo

if not shared.nexoIndependent then
	loadstring(downloadFile('nexo/games/universal.lua'), 'universal')()
	if isfile('nexo/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('nexo/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		if not shared.nexoDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/nexohub1/nexo/'..readfile('nexo/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('nexo/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
			end
		end
	end
	finishLoading()
else
	nexo.Init = finishLoading
	return nexo
end

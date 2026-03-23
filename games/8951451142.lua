local nexo = shared.nexo
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and nexo then
		nexo:CreateNotification('nexo', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
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

nexo.Place = 8768229691
if isfile('nexo/games/'..nexo.Place..'.lua') then
	loadstring(readfile('nexo/games/'..nexo.Place..'.lua'), 'skywars')()
else
	if not shared.nexoDeveloper then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/nexohub1/nexo/'..readfile('nexo/profiles/commit.txt')..'/games/'..nexo.Place..'.lua', true)
		end)
		if suc and res ~= '404: Not Found' then
			loadstring(downloadFile('nexo/games/'..nexo.Place..'.lua'), 'skywars')()
		end
	end
end

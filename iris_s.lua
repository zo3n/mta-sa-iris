local botName = "Iris"
local dictionaryKey = "1b29cb57-4f3d-43d7-a25b-36380da89068"
local players = {}

local mysql = {
	user = "nc",
	password = "UIh5g1iKG5o1h5ah5kg1",
	port = "3306",
	host = "37.59.108.96",
	database = "unlimitedreborn"
}


-- Set up MySQL Database 
local MySQL = dbConnect("mysql", string.format("dbname=%s;host=%s;port=%s", mysql.database, mysql.host, mysql.port), mysql.user, mysql.password);

if MySQL then
	outputDebugString("»" .. botName .. ": MySQL Connection Established!")
else
	outputDebugString("»" .. botName .. ": MySQL Connection Failed!", 2)
	return
end

--
function generateResponse(text, tArgs)
	text = text:gsub("%%someone%%", tArgs.name)
	text = text:gsub("%%someone2%%", tArgs.someone2)
	text = text:gsub("%%someone3%%", tArgs.someone3)
	text = text:gsub("%%someone4%%", tArgs.someone4)
	text = text:gsub("%%minutes%%", tArgs.minutes)
	text = text:gsub("%%seconds%%", tArgs.seconds)
	text = text:gsub("%%points%%", tArgs.points)
	text = text:gsub("%%score1%%", tArgs.score1)
	text = text:gsub("%%score2%%", tArgs.score2)
	text = text:gsub("%%website%%", tArgs.website)
	text = text:gsub("%%admins%%", tArgs.admins)
	text = text:gsub("%%song%%", tArgs.song)
	text = text:gsub("%%songby%%", tArgs.songby)
	text = text:gsub("%%team1%%", tArgs.team1)
	text = text:gsub("%%team2%%", tArgs.team2)
	text = text:gsub("%%room%%", tArgs.room)
	text = text:gsub("%%map%%", tArgs.map)
	return text
end

function chooseResponse(responseType, tArgs)

	-- Fetch response table
	local qh = dbQuery(MySQL, "SELECT * FROM iris_" .. responseType .. "_responses")
	local result = dbPoll(qh, -1)

	if result and type(result) == "table" then
		if (#result) > 0 then

			local index = math.random(1, #result)
			local theChosenOne = result[index]["response"]

			local processed = generateResponse(theChosenOne, tArgs)

			return processed

		end
	end

end


function irisTime(data, name, isCountry)
	if isElement(data) then
		if #name > 0 then
			fetchRemote ( "http://rc-rp.es/newPage/test.php?IP="..name[1], irisTime, "", false, true )
		else
			fetchRemote ( "http://rc-rp.es/newPage/test.php?IP="..getPlayerIP(data), irisTime, "", false, false )
		end
	elseif type(data) == "string" and data ~= "false" then
		local time = fromJSON(data)
		if type(time) == "table" then
			if isCountry then
				local str = generateLuaTime(2, time.name, string.format("%02d", time.hour), string.format("%02d", time.minute))
				outputChatBox(str, root, 255, 255, 255, true)
			else
				local str = generateLuaTime(1, "", string.format("%02d", time.hour), string.format("%02d", time.minute))
				outputChatBox(str, root, 255, 255, 255, true)
			end
		end
	end
end

function irisWeb()
	tArgs = generateResponseTable()
	tArgs.website = "sixth-sen.se"
	outputChatBox("#ff4081» "..botName..": #FFFFFF" .. chooseResponse("website", tArgs), root, 255, 255, 255, true)
end

function irisDate(data, name, isCountry)
	if isElement(data) then
		if #name > 0 then
			fetchRemote ( "http://rc-rp.es/newPage/test.php?IP="..name[1], irisDate, "", false, true )
		else
			fetchRemote ( "http://rc-rp.es/newPage/test.php?IP="..getPlayerIP(data), irisDate, "", false, false )
		end
	elseif type(data) == "string" and data ~= "false" then
		local time = fromJSON(data)
		if type(time) == "table" then
			local month = getRealMonth(time.month)
			if isCountry then
				local str = generateLuaDate(2, time.name, time.month, month, time.day, time.year)
				outputChatBox(str, root, 255, 255, 255, true)
			else
				local str = generateLuaDate(1, time.name, time.month, month, time.day, time.year)
				outputChatBox(str, root, 255, 255, 255, true)
			end
		end
	end
end

-- Fat ass bitch function (dont say i didnt warn you)
function irisDefine(data, name, player, word)

	-- If it's a player, then we need to fetch data
	if isElement(data) then
		if #name > 0 then
			fetchRemote( "http://www.dictionaryapi.com/api/v1/references/collegiate/xml/" .. tostring(name[1]) .. "?key=" .. dictionaryKey, irisDefine, "", false, data, tostring(name[1]) )
			outputDebugString("started fetching")
		end
	else
		
		local temp_file_name = "temp_" .. tostring(getTickCount())

		-- Make sure file with this name doesnt exist
		if fileExists(temp_file_name) then
			fileDelete(temp_file_name)
		end

		local temp_file = fileCreate(temp_file_name)

		if temp_file then
			
			fileWrite(temp_file, data)
			fileClose(temp_file)

			-- Now open it as xml file
			local xml = xmlLoadFile(temp_file_name)

			if xml then

				
				for i, v in pairs(xmlNodeGetChildren(xml)) do
					
					-- Look only for our word
					if i == 1 then

						for _, vv in pairs(xmlNodeGetChildren(v)) do

							if xmlNodeGetName(vv) == "def" then
								
								for _, vvv in pairs(xmlNodeGetChildren(vv)) do									

									if xmlNodeGetName(vvv) == "dt" then
										outputChatBox("#ff4081» "..botName..": #FFFFFFDefinition of word " .. word .. " is: " .. string.sub(xmlNodeGetValue(vvv), 2, #xmlNodeGetValue(vvv)), root, 255, 255, 255, true)
										break
									end

								end

							end

						end

					else
						break
					end

				end


				xmlUnloadFile(xml)

			end

		end

		-- Delete temp file when finished --
		if fileExists(temp_file_name) then
			fileDelete(temp_file_name)
		end

	end
end

function getPlayerMagicallyFromShortNick(stringPlayer)
	for _, v in pairs(getElementsByType("player")) do
		if getPlayerName(v):find(stringPlayer) then
			return v
		end
	end
	return false
end

function generateResponseTable()
local t = {
			someone = "",
			someone2 = "",
			someone3 = "",
			someone4 = "",
			minutes = "",
			seconds = "",
			points = "",
			score1 = "",
			score2 = "",
			website = "",
			admins = "",
			song = "",
			songby = "",
			team1 = "",
			team2 = "",
			room = "",
			map = ""
	}
	return t
end

function irisPlaytime(data, otherPlayerNick) -- todo

	if isElement(data) and otherPlayerNick and getPlayerMagicallyFromShortNick(otherPlayerNick) then

		local id = getPlayerForumID(getPlayerMagicallyFromShortNick(otherPlayerNick))

		local tArgs = generateResponseTable()
		tArgs.someone = players[id].name
		tArgs.minutes = players[id].minutes
		tArgs.seconds = players[id].seconds

		outputChatBox("#ff4081» "..botName..": #FFFFFF" .. chooseResponse("playtime", tArgs), root, 255, 255, 255, true)

	end
end

function irisAdmins()
	local admins = {}
	local str = "None"
	local tArgs = generateResponseTable()
	for _, player in pairs(players) do
		if player.isAdmin then
			admins[#admins + 1] = player.name
		end
	end
	if (#admins) > 0 then
		
		str = adminResponses[math.random(1, #adminResponses)] .. " "

		for i, admin in pairs(admins) do
			if i ~= (#admins) then
				str = str .. admin .. ", "
			else
				str = str .. admin
			end
		end

	end
	tArgs.admins = str
	outputChatBox("#ff4081» "..botName..": #FFFFFF" .. chooseResponse("admin", tArgs), root, 255, 255, 255, true)
end

function irisMute(admin, playerNick)

	local adminID = getPlayerForumID(admin)

	if players[adminID].isAdmin then

		local targetPlayer = getPlayerMagicallyFromShortNick(playerNick)

		if targetPlayer then
			
			-- mute teh playe

			tArgs = generateResponseTable()
			tArgs.someone = players[adminID].name
			tArgs.someone2 = getPlayerName(targetPlayer)

			outputChatBox("#ff4081» "..botName..": #FFFFFF" .. chooseResponse("mute", tArgs), root, 255, 255, 255, true)
		end

	end

end

function irisBuyMap(player, mapName)

	-- magic
	if mapExists(mapName) and playerHasMoney(player) then

		local id = getPlayerForumID(player)
		local tArgs = generateResponseTable()

		tArgs.someone = players[id].name
		tArgs.map = mapName

		outputChatBox("#ff4081» "..botName..": #FFFFFF" .. chooseResponse("buy", tArgs), player, 255, 255, 255, true)

	else
		-- you failed in life
	end

end

function irisSaveDemo(player, whatDemo)

	-- black magic

	if succesefueelle then

		outputChatBox("#ff4081» "..botName..": #FFFFFF" .. chooseResponse("demo", generateResponseTable()), player, 255, 255, 255, true)

	end

end

function irisJoin(player, roomIdentifier)

	if isValidRoom(roomIdentifier) and playerNotAlreadyInIt(player) then

		local tArgs = generateResponseTable()

		tArgs.room = getRoomName(roomIdentifier)

		outputChatBox("#ff4081» "..botName..": #FFFFFF" .. chooseResponse("join", tArgs), player, 255, 255, 255, true)

	end

end

function irisMentor(player, theMentor)

	if getPlayerMagicallyFromShortNick(theMentor) then

		-- some shit

		local tArgs = generateResponseTable()

		tArgs.someone = getPlayerName(player)
		tArgs.someone2 = getPlayerName(getPlayerMagicallyFromShortNick(theMentor))

		outputChatBox("#ff4081» "..botName..": #FFFFFF" .. chooseResponse("mentor", tArgs), player, 255, 255, 255, true)

	end

end

function irisDontDisturb(player)
	-- do magic to not disturb
	outputChatBox("#ff4081» "..botName..": #FFFFFF" .. chooseResponse("disturb", generateResponseTable()), player, 255, 255, 255, true)
end

function irisNews(player)
	-- magically get news --
	local news = ""
	outputChatBox("#ff4081» "..botName..": #FFFFFF" .. news .. " " .. chooseResponse("news", generateResponseTable()), player, 255, 255, 255, true)
end

function irisLastCW(player)
	local team1, team2 = "something", "other" -- team names of teams who were in cw, and TEAM 1 MUST BE WINNER TEAM
	local score1, score2 = "20", "0" -- how much each team scored points

	local tArgs = generateResponseTable()

	tArgs.team1 = team1
	tArgs.team2 = team2
	tArgs.score1 = score1
	tArgs.score2 = score2

	outputChatBox("#ff4081» "..botName..": #FFFFFF" .. chooseResponse("cw", tArgs), player, 255, 255, 255, true)
end

function irisSong(player)
	local namedBy = ""
	local songName = ""
	local tArgs = generateResponseTable()
	tArgs.song = songName
	tArgs.songby = namedBy
	outputChatBox("#ff4081» "..botName..": #FFFFFF" .. chooseSongResponse("song", tArgs), player, 255, 255, 255, true)
end

function irisSynonym(player)
	-- hello to a wonderful person who is reading this :) have a nice day!
end

function irisEtymology(player)
	-- who the hell knows
end




dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_playtime_responses (response varchar(255))")
dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_mute_responses (response varchar(255))")
dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_buy_responses (response varchar(255))")
dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_demo_responses (response varchar(255))")
dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_join_responses (response varchar(255))")
dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_mentor_responses (response varchar(255))")
dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_disturb_responses (response varchar(255))")
dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_news_responses (response varchar(255))")
dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_cw_responses (response varchar(255))")
dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_song_responses (response varchar(255))")
dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_admin_responses (response varchar(255))")
dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_website_responses (response varchar(255))")
dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_commands (command varchar(255), type varchar(255), ignoreArguments INT, dataArguments INT, lastKeyword varchar(255))")


function addCommand(p, _, commandName, isAdmin, ignoreArguments, dataArguments, lastKeyword)

	if commandName then

		dbExec(MySQL, "INSERT INTO iris_commands (command, type, ignoreArguments, dataArguments, lastKeyword) VALUES (?, ?, ?, ?, ?)", commandName, (isAdmin and isAdmin == "admin") and "admin" or "user", (ignoreArguments and tonumber(ignoreArguments)) and tonumber(ignoreArguments) or 0, (dataArguments and tonumber(dataArguments)) and tonumber(dataArguments) or 0, lastKeyword and lastKeyword or "")
		outputChatBox("Added command '" .. commandName .. "' to command list.", p, 0, 255, 0)

	end

end
addCommandHandler("addcommand", addCommand)

function removeCommand(p, _, commandName)

	if commandName then

		dbExec(MySQL, "DELETE FROM iris_commands WHERE command=?", commandName)
		outputChatBox("Deleted command '" .. commandName .. "' from command list.", p, 255, 0, 0)

	end

end
addCommandHandler("removecommand", removeCommand)

function testCommand(p, _, command)
	if command then
		outputChatBox("Command '" .. command .. "' " .. (doesCommandExist(command) and "exists." or "doesn't exist."), p)
	end
end
addCommandHandler("commandexists", testCommand)

function commandType(p, _, command)

	if command and doesCommandExist(command) then
		outputChatBox("Command type of '" .. command .. "' is: " .. tostring(getCommandType(command)), p)
	end

end
addCommandHandler("commandtype", commandType)

function outputCommands(p)

	local commands = getIrisCommands()
	outputChatBox(" ", p)
	outputChatBox("================ IRIS COMMAND LIST ==================", p, 255, 255, 255)

	for i, v in pairs(commands) do
		outputChatBox("[" .. v["command"] .. "] type: " .. v["type"] .. " ignoreArguments: " .. v["ignoreArguments"] .. " dataArguments: " .. v["dataArguments"] .. " lastKeyword: " .. v["lastKeyword"], p, 255, 255, 255)
	end

	outputChatBox("===================================================", p, 255, 255, 255)

end
addCommandHandler("commands", outputCommands)



function getIrisCommands()

	local qh = dbQuery(MySQL, "SELECT * FROM iris_commands")
	local result = dbPoll(qh, -1)

	if result and type(result) == "table" then
		if (#result) > 0 then
			return result
		end
	end

	return false

end

function doesCommandExist(command)

	local qh = dbQuery(MySQL, "SELECT * FROM iris_commands WHERE command=?", command)
	local result = dbPoll(qh, -1)

	if result and type(result) == "table" then
		if (#result) > 0 then
			return true
		end
	end

	return false

end

function getCommandType(command)

	local qh = dbQuery(MySQL, "SELECT * FROM iris_commands WHERE command=?", command)
	local result = dbPoll(qh, -1)

	if result and type(result) == "table" then
		if (#result) > 0 then
			return result[1]["type"]
		end
	end

	return false;

end

function getCommand(command)

	local qh = dbQuery(MySQL, "SELECT * FROM iris_commands WHERE command=?", command)
	local result = dbPoll(qh, -1)

	if result and type(result) == "table" then
		if (#result) > 0 then
			return result[1]
		end
	end

	return false;

end

function addResponse(p, _, toWhatCommand, ...)

	if toWhatCommand and type(toWhatCommand) == "string" and (#{...}) > 0 then

		local whatResponse = table.concat({...}, " ")

		dbExec(MySQL, "CREATE TABLE IF NOT EXISTS iris_" .. toWhatCommand:lower() .. "_responses (response varchar(255))")
		dbExec(MySQL, "INSERT INTO iris_" .. toWhatCommand:lower() .. "_responses (response) VALUES(?)", whatResponse)

		outputChatBox("Response added successfully.", p, 0, 255, 0)

	end

end
addCommandHandler("addresponse", addResponse)

function getResponses(p, _, whatCommand)
	if whatCommand then
		outputChatBox(" ")
		outputChatBox(whatCommand .. " responses:", p, 255, 255, 255)
		local qh = dbQuery(MySQL, "SELECT * FROM iris_" .. whatCommand:lower() .. "_responses")
		local result = dbPoll(qh, -1)

		if result and type(result) == "table" then
			if (#result) > 0 then

				for i,v in pairs(result) do
					outputChatBox(v["response"], p, 255, 255, 255)
				end

			end
		end

	end
end
addCommandHandler("getresponses", getResponses)

function doesCommandHaveKeyword(command)

	local qh = dbQuery(MySQL, "SELECT * FROM iris_commands WHERE command=?", command)
	local result = dbPoll(qh, -1)

	if result and type(result) == "table" then
		if (#result) > 0 then
			return (#result[1]["lastKeyword"]) > 0
		end
	end

end


addEventHandler("onPlayerChat", root, 
	function(message, msgType)

		if msgType == 0 then

			-- If message starts with 'iris' and there's a space after 's' so that it doesnt look like e.g 'irisdefine' instead of 'iris define'
			if message:lower():sub(1, 4) == "iris" and message:sub(5, 5) == " " then

				cancelEvent(true) -- don't output iris command message to chat

				-- Extract vital information from teh message
				local processed = message:sub(6, #message)
				local args = split(processed, " ")
				local command = args[1]
				local parameters = {}

				-- Check if command exists
				if doesCommandExist(command) then

					-- Get parameters
					local commandData = getCommand(command)

					if commandData["lastKeyword"] then

						local keyword = commandData["lastKeyword"]
						local parameterIndex

						-- Find keyword index and start getting parameters from there
						for i = 1, (#args) do
							if args[i] == keyword then
								parameterIndex = i
								break
							end
						end

						-- Extract parameters and ignore the command from args
						for i = parameterIndex + 1, (#args) do
							parameters[#parameters + 1] = args[i]
						end

						-- Call function resposible for this command and give it parameterrs fuck that word really
						_G["iris_"..command](parameters)

					end

				end

			end

		end

	end
)

addEventHandler("onResourceStart", resourceRoot, 
	function()

		-- Create functions in _G for all current functions
		for i,v in pairs(getIrisCommands()) do
			
			if (#v["lastKeyword"]) == 0 then
				_G["iris_" .. v["command"]] = function(...) end
				outputDebugString("Registered function iris_" .. v["command"] .. " to _G")
			else
				_G["iris_" .. v["command"] .. "_" .. v["lastKeyword"]] = function(...) end
				outputDebugString("Registered function iris_" .. v["command"] .. "_" .. v["lastKeyword"])
			end

		end

	end
)

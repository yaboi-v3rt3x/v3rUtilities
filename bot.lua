local bootTime = os.time()
local disconnected = false

local altctrl = _G.ALTCTRL or false
local SPIN_POWER = 100
local FLOAT_HEIGHT = 9

local bot = game.Players.LocalPlayer
local HH = bot.Character.Humanoid.HipHeight

for i, plr in pairs(game.Players:GetPlayers()) do
	for i, obj in pairs(plr:GetChildren()) do
		if obj.Name == "v3rBotBlacklist" then
			obj:Destroy()		
		end
	end
end

--[[ configuration ]]--

local whitelisted = {
	bot.Name,
}

local showbotchat = _G.showBotChat or false --setting this to true will cause all messages sent by either commands or v3rBot to begin with [v3rBot]
local allwhitelisted = _G.defaultAllWhitelisted or false --set to true if you want everyone to be whitelisted, v3rt3x is not responsible for anything players make you do or say.
local randommoveinteger = _G.defaultRandomMoveInteger or 15 --interval in which how long randommove waits until choosing another direction
local prefix = _G.defaultPrefix or "!" --DO NOT SET TO MORE THAN 1 CHARACTER!

if _G.preWhitelisted and type(_G.preWhitelisted) == "table" then
	for i, v in pairs(_G.preWhitelisted) do
		table.insert(whitelisted, v)
	end
end

if prefix:len() > 1 then
	warn("v3rBot // Prefix cannot be more than 1 character long!")
	return
end

--[[ end configs, don't edit this especially if you have no idea what Lua is lmao ]]--

local v3rBotversion = "v0.1"
local v3rBotchangelogs = "Nothing New"

local gameData = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
local status = nil
local followplr = nil
local copychatplayer = nil

local TS = game:GetService("TweenService")

local TI = TweenInfo.new(
	2.5,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local function chat(msg)
	if showbotchat == true then
		game.TextChatService.TextChannels.RBXGeneral:SendAsync("[v3rBot]: " .. msg)
	else
		game.TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
	end
end

local funfacts = {
	"My dad came back from getting the milk 0.03 seconds ago.",
	"We are playing Roblox.",
	"If you spend a penny, you lose that penny.",
	"v3rBot is a self-bot, meaning that, yes, I AM A REAL PERSON. I'm watching!",
	"Among Us is extremely old.",
	"Press Alt + F4 to get 1 billion dollars on the spot.",
	"At the time of writing this fun fact list, there are 6 people in the server.",
	"v3rBot was first tested in the game: a literal baseplate.",
	"I found a lucky penny!",
	"You found this fun fact.",
	"The sandwich was invented in the 1700s.",
	"If you drink poison, you might die.",
	"Hot water will turn into ice faster than cold water.",
	"The Mona Lisa has no eyebrows.",
	"The strongest muscle in the body is the tongue.",
	"Ants take rest for around 8 minutes in a 12-hour period.",
	"'I am' is the shortest complete sentence in the English language.",
	"Coca-Cola was originally green.",
	"I got most of these fun facts from Google.",
	"Rabbits can't get sick.",
	"McDonald's invented a sweet-tasting type of broccoli.",
	"Water makes different sounds depending on its temperature.",
}

local messageReceived = game.TextChatService.TextChannels.RBXGeneral.MessageReceived

local commandsMessage = {
	"cmds, setprefix <newPrefix>, help <command>, aliases <command>, ping, executor, setstatus <newStatus>, clearStatus, fps, time, to, speed, say, altcontrol"
	"reset, coinflip, jump, sit, follow, unfollow, orbit <speed> <radius>, spin <speed>, unspin, copychat <player>, uncopychat, float <height>, unfloat,"
	"funfact, rush, randommove, randomplayer, rickroll, random <min> <max>, pick <options>, announce <announcement>, playercount, maxplayers, gamename,"
	"catch <player>, whitelist <player>, blacklist <player>,  bring, walkto <player>, enablecommand, disablecommand <command>, math <operation> <nums>"
}

local orbitcon

local function orbit(target, speed, radius)
	local r = tonumber(radius) or 10
	local rps = tonumber(speed) or math.pi
	local orbiter = bot.Character.HumanoidRootPart
	local angle = 0
	orbitcon = game:GetService("RunService").Heartbeat:Connect(function(dt)
		if not target.Character then return end
		origin = target.Character.HumanoidRootPart.CFrame
		angle = (angle + dt * rps) % (2 * math.pi)
		orbiter.CFrame = origin * CFrame.new(math.cos(angle) * r, 0, math.sin(angle) * r)
	end)
end

local function unorbit()
	orbitcon:Disconnect()
end

local commands --don't change, could lead to errors

local function checkCommands(cmd)
	for i, cmds in pairs(commands) do
		if cmds == cmd or table.find(cmds.Aliases, cmd) or cmds.Name == cmd then
			return cmds	
		end
	end
	
	return nil
end

local rushing = false
local rickrolling = false

local function searchPlayers(query)
	query = string.lower(query)
	
	for i, player in pairs(game.Players:GetPlayers()) do
		if string.find(string.lower(player.DisplayName), query) or string.find(string.lower(player.Name), query) then
			return player
		end
	end
	
	return nil
end

commands = {
	cmds = {
		Name = "cmds",
		Aliases = {"commands"},
		Use = "Lists all commands!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			task.spawn(function()
				for i, cmd in pairs(commandsMessage) do
					chat(cmd)
					wait(0.5)
				end
			end)
		end,
	},
	aliases = {
		Name = "aliases",
		Aliases = {},
		Use = "Lists the aliases for the given command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			task.spawn(function()
				if not args[2] then return end
				
				local cmd = checkCommands(args[2])
				
				local function getAliases(c)
					local str = ""
					
					if #c.Aliases == 0 then return "None" end
					
					for i, a in pairs(c.Aliases) do
						str = str .. a .. ", "
					end
					
					return str
				end
				
				if cmd then
					chat(cmd.Name .. " - " .. getAliases(cmd))
				else
					chat("Invalid command!")
				end
			end)
		end,
	},
	help = {
		Name = "help",
		Aliases = {"help"},
		Use = "Tells you the use of the given command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			task.spawn(function()
				if not args[2] then
					return
				end
				
				if string.sub(args[2], 1, 1) == prefix then
					args[2] = string.sub(args[2], 2)
				end
			
				local cmd = checkCommands(args[2])
				
				if cmd then
					chat(cmd.Name .. " - " .. cmd.Use)
				else
					chat("Invalid command!")
				end
			end)
		end,
	},
	reset = {
		Name = "reset",
		Aliases = {"re"},
		Use = "Respawns v3rBot!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			local hum = bot.Character:FindFirstChildWhichIsA("Humanoid")
			
			if hum then
				hum.Health = 0
			end
		end,
	},
	rejoin = {
		Name = "rejoin",
		Aliases = {"rj"},
		Use = "Rejoins v3rBot!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			if speaker ~= bot.Name and altctrl == false then chat("Invalid permissions to rejoin.") return end
		
			if #game.Players:GetPlayers() <= 1 then
				print("Rejoining (NEW SERVER)")
				game.Players.LocalPlayer:Kick("\nv3rBot - Rejoining...")
				wait()
				game:GetService('TeleportService'):Teleport(game.PlaceId, game.Players.LocalPlayer)
			else
				print("v3rBot is rejoining...")
				game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
			end
		end,
	},
	catch = {
		Name = "catch",
		Aliases = {"catchin4k", "c14"},
		Use = "Makes v3rBot catch the given player in 4K!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			local plr
			
			if args[2] then
				if args[2] == "random" then
					local players = game.Players:GetPlayers()
					
					plr = players[math.random(1, #players)]
				else
					local searched = searchPlayers(args[2])
				
					if searched ~= nil then
						plr = searched
					else
						chat("Invalid player!")
						return
					end
				end
			else
				plr = game.Players:FindFirstChild(speaker)
			end
			
			if plr then
				bot.Character:SetPrimaryPartCFrame(CFrame.new(plr.Character.HumanoidRootPart.Position))
				chat("📸 CAUGHT IN 4K BY V3RBOT 📸")
			end
		end,
	},
	ping = {
		Name = "ping",
		Aliases = {"getping"},
		Use = "Chats v3rBot's ping!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			chat("Ping: " .. tostring(math.floor(game:GetService("Stats").PerformanceStats.Ping:GetValue() + 0.5)) .. " ms")
		end,
	},
	executor = {
		Name = "executor",
		Aliases = {"identifyexecutor", "getexec", "exec"},
		Use = "Gives you the executor that is running v3rBot!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			chat("Executor: " .. identifyexecutor() or "Unknown")
		end,
	},
	gamename = {
		Name = "gamename",
		Aliases = {"gn"},
		Use = "Chats the current game's name!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			chat(gameData.Name)
		end,
	},
	playercount = {
		Name = "playercount",
		Aliases = {"plrcount"},
		Use = "Chats the current amount of players!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			chat(tostring(#game.Players:GetPlayers()))
		end,
	},
	maxplayers = {
		Name = "maxplayers",
		Aliases = {"maxplrs"},
		Use = "Chats the current server's maximum player count!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			chat(tostring(game.Players.MaxPlayers))
		end,
	},
	unfollow = {
		Name = "unfollow",
		Aliases = {"unfollowplr"},
		Use = "Stops following the player!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				task.spawn(function()
					followplr = nil
					wait()
					bot.Character.Humanoid:MoveTo(bot.Character.HumanoidRootPart.Position)
				end)
			end)
		end,
	},
	follow = {
		Name = "follow",
		Aliases = {"followplr"},
		Use = "Makes v3rBot follow the player that chatted the command or the given player!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			local plr
			
			if args[2] then
				if args[2] == "random" then
					local players = game.Players:GetPlayers()
					
					plr = players[math.random(1, #players)]
				else
					local searched = searchPlayers(args[2])
				
					if searched ~= nil then
						plr = searched
					else
						chat("Invalid player!")
						return
					end
				end
			else
				plr = game.Players:FindFirstChild(speaker)
			end
			
			followplr = plr
		end,
	},
	pick = {
		Name = "pick",
		Aliases = {"choose"},
		Use = "Picks an item from the given options.",
		Enabled = true,
		CommandFunction = function(msg, args)
			local choosefrom = {}
		
			for i, opt in pairs(args) do
				if i >= 2 then
					table.insert(choosefrom, opt)
				end
			end
			
			local chosen = choosefrom[math.random(1, #choosefrom)]
			
			if chosen then
				chat("v3rBot chose: " .. chosen)
			end
		end,
	},
	sit = {
		Name = "sit",
		Aliases = {},
		Use = "Makes v3rBot sit!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			bot.Character.Humanoid.Sit = true
		end,
	},
	jump = {
		Name = "jump",
		Aliases = {},
		Use = "Makes v3rBot jump!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			bot.Character.Humanoid.Jump = true
		end,
	},
	say = {
		Name = "say",
		Aliases = {"chat"},
		Use = "Says the given message in chat!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			local tosay
			
			if args[1] == "say" then
				tosay = string.sub(msg, 6)
			else
				tosay = string.sub(msg, 8)
			end
			
			local speakerplayer = game.Players:FindFirstChild(speaker)
			
			if not speakerplayer then return end
			
			if altctrl then chat(tosay) else chat(speakerplayer.DisplayName .. ": " .. tosay) end
		end,
	},
	announce = {
		Name = "announce",
		Aliases = {},
		Use = "Makes an announcement via chat, a owner-only command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			if speaker ~= bot.Name then return end
		
			chat("-- ANNOUNCEMENT -- ")
			wait()
			chat(string.sub(msg, 10))
			wait()
			chat("-- ANNOUNCEMENT --")
		end,
	},
	whitelist = {
		Name = "whitelist",
		Aliases = {"wl"},
		Use = "Whitelists the given player, meaning they can use v3rBot. An owner-only command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			local towhitelist = args[2]
			
			if speaker ~= bot.Name then return end
			
			if towhitelist then
				if towhitelist == "all" then
					for i, player in pairs(game.Players:GetPlayers()) do
						table.insert(whitelisted, player.Name)
						local bl = player:FindFirstChild("v3rBotBlacklist")
						if bl then bl:Destroy() else warn(player.DisplayName .. " was not blacklisted!") end
					end
					
					allwhitelisted = true
					
					chat("Whitelisted all players that are currently in the game! Type " .. prefix .. "cmds to view commands.")
				else
					local plr = searchPlayers(towhitelist)
					
					if plr then
						table.insert(whitelisted, plr.Name)
						local bl = plr:FindFirstChild("v3rBotBlacklist")
						if bl then bl:Destroy() else warn(player.DisplayName .. " was not blacklisted!") end
						chat("Whitelisted " .. plr.DisplayName .. "! Type " .. prefix .. "cmds to view commands.")
					else
						chat("Failed to whitelist player - User not found!")
					end
				end
			end
		end,
	},
	blacklist = {
		Name = "blacklist",
		Aliases = {"bl"},
		Use = "Blacklists the given player meaning they cannot use v3rBot. Owner-only command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			local toblacklist = args[2]
			
			if speaker ~= bot.Name then return end
			
			if toblacklist then
				if toblacklist == "all" then
					for i, p in pairs(game.Players:GetPlayers()) do
						local alrbl = p:FindFirstChild("v3rBotBlacklist")
						
						if alrbl then alrbl:Destroy() end
					
						local new = Instance.new("BoolValue")
						new.Parent = p
						new.Name = "v3rBotBlacklist"
						new.Value = true
					end
					
					allwhitelisted = false
					
					chat("Blacklisted all players that are currently in the game! They can no longer run commands.")
				else
					local plr = searchPlayers(toblacklist)
					
					if plr then
						local alrbl = plr:FindFirstChild("v3rBotBlacklist")
						
						if alrbl then alrbl:Destroy() end
					
						local new = Instance.new("BoolValue")
						new.Parent = plr
						new.Name = "v3rBotBlacklist"
						new.Value = true
						alwhitelisted = false
						chat("Blacklisted " .. plr.DisplayName .. "! They can no longer run commands.")
					else
						chat("Failed to blacklist player - User not found!")
					end
				end
			end
		end,
	},
	coinflip = {
		Name = "coinflip",
		Aliases = {"flip", "coin"},
		Use = "Flips a coin using a randomly generated number from 1 to 2.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			local flipped = math.random(1, 2)
			
			if flipped == 1 then
				chat("HEADS!")
			elseif flipped == 2 then
				chat("TAILS!")
			else
				chat("Whoops! An unknown error occured while flipping the coin. That's a bit embarrasing.")
			end
		end,
	},
	random = {
		Name = "random",
		Aliases = {},
		Use = "Generates a random number between the given numbers!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			if args[2] and args[3] then
				local rnd = math.random(tonumber(args[2]), tonumber(args[3]))
				
				if rnd then
					chat("v3rBot // Generated random number between " .. args[2] .. " and " .. args[3] .. ": " .. rnd)
				else
					chat("Aw, snap! An error occured while generating a random number.")
				end
			end
		end,
	},
	bring = {
		Name = "bring",
		Aliases = {},
		Use = "Brings v3rBot to the player that chatted the command.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local plr = game.Players:FindFirstChild(speaker)
			
				if plr then
					bot.Character:SetPrimaryPartCFrame(plr.Character.HumanoidRootPart.CFrame)
				end
			end)
		end,
	},
	copychat = {
		Name = "copychat",
		Aliases = {"cc", "copyc", "cchat"},
		Use = "Makes v3rBot copy everything the given player says. Using on v3rbot will break v3rBot.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local player = nil
			
				if args[2] then
					if args[2] == "random" then
						player = game.Players:GetPlayers()[math.random(1,#game.Players:GetPlayers())]
					else
						player = searchPlayers(args[2])
					end
				else
					player = game.Players:FindFirstChild(speaker)
				end
				
				if player then
					copychatplayer = player
					chat("Now copying " .. player.DisplayName .. "'s chat!")
				else
					chat("Invalid player!")
				end
			end)
		end,
	},
	uncopychat = {
		Name = "uncopychat",
		Aliases = {"uncc", "uncopyc", "uncchat"},
		Use = "Makes v3rBot stop copying everything the copychat player says.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if copychatplayer then
					chat("Stopped copying " .. copychatplayer.DisplayName .. "!")
					copychatplayer = nil
				else
					chat("v3rBot is not copying anyone!")
				end
			end)
		end,
	},
	to = {
		Name = "to",
		Aliases = {},
		Use = "Teleports v3rBot to the given player.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not args[2] then return end
			
				local plr = nil
				
				if args[2] == "random" then
					local players = game.Players:GetPlayers()
					
					plr = players[math.random(1, #players)]
				else
					plr = searchPlayers(args[2])
				end
			
				if plr then
					bot.Character:SetPrimaryPartCFrame(plr.Character.HumanoidRootPart.CFrame)
				else
					chat("Invalid player!")
				end
			end)
		end,
	},
	walkto = {
		Name = "walkto",
		Aliases = {"come"},
		Use = "Makes v3rBot walk to the player that chatted the command or the given player!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local plr
				
				if not args[2] then plr = game.Players:FindFirstChild(speaker) end
				
				if args[2] and args[2] == "random" then
					plr = game.Players:GetPlayers()[math.random(1,#game.Players:GetPlayers())]
				elseif args[2] then
					plr = searchPlayers(args[2])
				end
			
				if plr and plr:IsA("Player") then
					bot.Character.Humanoid:MoveTo(plr.Character.HumanoidRootPart.Position)
				else
					chat("Could not find player!")
				end
			end)
		end,
	},
	setprefix = {
		Name = "setprefix",
		Aliases = {"prefix"},
		Use = "Sets the prefix of v3rBot! Owner-only command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not args[2] then return end
			
				if speaker == bot.Name then
					if args[2] == "#" then return end
					if string.len(args[2]) >= 2 then chat("Maximum prefix length is 1 character!") return end
				
					prefix = args[2]
					chat("Successfully set prefix to '" .. prefix .. "'!")
				else
					chat("You do not have the permissions to run .setprefix!")
				end
			end)
		end,
	},
	setstatus = {
		Name = "setstatus",
		Aliases = {},
		Use = "Sets the status of v3rBot. When a status is set, the bot will no longer take commands.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not args[2] then return end
			
				if speaker == bot.Name then
					status = string.sub(msg, 12)
					chat("Successfully set status to '" .. status .. "'!")
				else
					chat("You do not have the permissions to run .setstatus!")
				end
			end)
		end,
	},
	clearstatus = {
		Name = "clearstatus",
		Aliases = {"nostatus"},
		Use = "Clears the status and allows the bot to take commands again!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if speaker == bot.Name then
					status = nil
					chat("Successfully cleared status!")
				else
					chat("You do not have the permissions to run .clearstatus!")
				end
			end)
		end,
	},
	funfact = {
		Name = "funfact",
		Aliases = {"fact", "randomfact"},
		Use = "Chats a random fun fact!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local rnd = funfacts[math.random(1, #funfacts)]
				
				chat("Fun Fact: " .. rnd)
			end)
		end,
	},
	time = {
		Name = "time",
		Aliases = {"currenttime"},
		Use = "Gives you v3rBot's current time in its timezone.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				chat("v3rBot's current time is: " .. os.date("%I:%M:%S %p"))
			end)
		end,
	},
	rickroll = {
		Name = "rickroll",
		Aliases = {"rick", "roll", "rr"},
		Use = "Rickrolls the chat!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				task.spawn(function()
					rickrolling = true
					chat("Never gonna give you up!")
					wait(1)
					chat("Never gonna let you down!")
					wait(1)
					chat("Never gonna run around, and")
					wait(1)
					chat("Desert you!")
					rickrolling = false
				end)
			end)
		end,
	},
	walkspeed = {
		Name = "walkspeed",
		Aliases = {"speed"},
		Use = "Sets v3rBot's walkspeed to given speed!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not args[2] then return end
				if not tonumber(args[2]) then return end
				
				if tonumber(args[2]) > 1000 then
					chat("Whoops! That speed is over the speed limit of 1000.")
					return
				end
			
				bot.Character.Humanoid.WalkSpeed = tonumber(args[2])
				
				chat("Changed walkspeed to " .. args[2] .. "!")
			end)
		end,
	},
	fps = {
		Name = "fps",
		Aliases = {},
		Use = "Chats v3rBot's current FPS!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				chat("v3rBot's FPS is: " .. tostring(math.round(game.Workspace:GetRealPhysicsFPS())))
			end)
		end,
	},
	math = {
		Name = "math",
		Aliases = {},
		Use = "Does the given operation on the given arguments.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not args[2] then return end
				if not args[3] then return end
				if not args[4] then return end
				
				local operations = {
					"add",
					"subtract",
					"multiply",
					"divide"
				}
				
				local operation = args[2]
				
				if not table.find(operations, operation) then
					chat("Invalid operation!")
					return
				end
				
				local result
				
				local nums = {}
				
				for i, arg in pairs(args) do
					if i > 2 then
						if tonumber(arg) then
							table.insert(nums, tonumber(arg))
						else
							chat("Attempt to do math on unknown characters!")
							return	
						end
					end
				end
				
				for i, num in pairs(nums) do
					if i == 1 then
						result = num
					else
						if operation == "add" then
							result = result + num
						elseif operation == "subtract" then
							result = result - num
						elseif operation == "divide" then
							result = result / num
						elseif operation == "multiply" then
							result = result * num
						end
					end
				end
				
				chat("Result: " .. tostring(result))
			end)
		end,
	},
	disablecommand = {
		Name = "disablecommand",
		Aliases = {"disablecmd", "cmddisable"},
		Use = "Disables the specified command. Owner-only command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not speaker == bot.Name then chat("You do not have permission to disable this command.") return end
			
				if not args[2] then return end
			
				local cmd = checkCommands(args[2])
			
				if not cmd then
					chat("Invalid command!")
					return
				end
				
				cmd.Enabled = false
				chat("Disabled command: " .. cmd.Name .. "!")
			end)
		end,
	},
	enablecommand = {
		Name = "enablecommand",
		Aliases = {"enablecmd", "cmdenable"},
		Use = "Enables the specified command! Owner-only command!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if not speaker == bot.Name then chat("You do not have permission to enable this command.") return end
			
				if not args[2] then return end
			
				local cmd = checkCommands(args[2])
			
				if not cmd then
					chat("Invalid command!")
					return
				end
				
				cmd.Enabled = true
				chat("Enabled command: " .. cmd.Name .. "!")
			end)
		end,
	},
	randomplayer = {
		Name = "randomplayer",
		Aliases = {"rndplayer", "randomplr", "player"},
		Use = "Gets a random player that is currently in the server and chats their name!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local rnd = game.Players:GetPlayers()[math.random(1,#game.Players:GetPlayers())]
				
				if rnd then
					chat("Random player: " .. rnd.DisplayName .. "(" .. rnd.Name .. ")")
				end
			end)
		end,
	},
	randommove = {
		Name = "randommove",
		Aliases = {"rndmove", "autowalk"},
		Use = "Toggles v3rBot's random movement feature!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				randommove = not randommove
				
				if randommove == true then
					chat("Enabled random move!")
				else
					chat("Disabled random move!")
				end
			end)
		end,
	},
	rush = {
		Name = "rush",
		Aliases = {"rushbegin"},
		Use = "Makes v3rBot turn into Rush from DOORS!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				if rushing == true then return end
				rushing = true
				chat("-lights flicker-")
				local origin = bot.Character.HumanoidRootPart.Position
				local startpos = bot.Character.HumanoidRootPart.Position - Vector3.new(-150, 0, 0)
				bot.Character:SetPrimaryPartCFrame(CFrame.new(startpos))
				wait(1.5)
				chat("-rush sounds-")
				local movetween = TS:Create(bot.Character.HumanoidRootPart, TI, {CFrame = CFrame.new(origin)})
				movetween:Play()
				movetween.Completed:Wait()
				chat("-rush screams-")
				wait(10)
				rushing = false
			end)
		end,
	},
	altcontrol = {
		Name = "altcontrol",
		Aliases = {"altctrl"},
		Use = "Removes the name from the .say command.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				altctrl = true
				chat("Enabled alt control mode!")
			end)
		end,
	},
	unaltcontrol = {
		Name = "unaltcontrol",
		Aliases = {"unaltctrl"},
		Use = "Adds the name to the .say command.",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				altctrl = false
				chat("Disabled alt control mode!")
			end)
		end,
	},
	spin = {
		Name = "spin",
		Aliases = {"rotate"},
		Use = "Makes the bot spin!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local pwr = 100
				
				if args[2] and tonumber(args[2]) then pwr = tonumber(args[2]) end
			
				local already = bot.Character.HumanoidRootPart:FindFirstChild("Spinner")
				
				if already then already:Destroy() end
			
				local spinner = Instance.new("BodyAngularVelocity")
				spinner.Name = "Spinner"
				spinner.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
				spinner.MaxTorque = Vector3.new(0,math.huge,0)
				spinner.AngularVelocity = Vector3.new(0,pwr,0)
			end)
		end,
	},
	unspin = {
		Name = "unspin",
		Aliases = {"unrotate"},
		Use = "Stops the spinning bot!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local spinner = game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("Spinner")
				if spinner then spinner:Destroy() end
			end)
		end,
	},
	float = {
		Name = "float",
		Aliases = {"levitate"},
		Use = "Floats the bot!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local f = 9
				if args[2] and tonumber(args[2]) then f = tonumber(args[2]) end
				bot.Character.Humanoid.HipHeight = f
			end)
		end,
	},
	unfloat = {
		Name = "unfloat",
		Aliases = {"unlevitate"},
		Use = "Unfloats the bot!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				bot.Character.Humanoid.HipHeight = HH
			end)
		end,
	},
	orbit = {
		Name = "orbit",
		Aliases = {"orbit"},
		Use = "Orbits the bot around the given player!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				local player = game.Players:FindFirstChild(speaker)
				
				if not player then return end
			
				orbit(player, args[2], args[3])
			end)
		end,
	},
	unorbit = {
		Name = "unorbit",
		Aliases = {"unorbit"},
		Use = "Halts the orbit!",
		Enabled = true,
		CommandFunction = function(msg, args, speaker)
			pcall(function()
				unorbit()
			end)
		end,
	},
}


local cmdcon = messageReceived:Connect(function(data)
	local message = data.Text
	
	local speakerplayer = game.Players:GetPlayerByUserId(data.TextSource.UserId)
    local speaker = speakerplayer.Name
	
	if not speakerplayer then return end

	local msg = string.lower(message)
	
	if string.sub(msg, 1, 1) == prefix then
		if speakerplayer:FindFirstChild("v3rBotBlacklist") then
			return
		end

		if not table.find(whitelisted, speaker) and allwhitelisted == false then
			return
		end
		
		if rickrolling == true then return end
	
		msg = string.sub(msg, 2)
		
		local args = string.split(msg, " ")
		
		local cmd = checkCommands(args[1])
		
		if status ~= nil and speaker ~= bot.Name then
			chat("v3rBot Status // " .. status .. " // Commands are disabled.")
			return
		end
		
		if cmd ~= nil then
			if cmd.Enabled == false then
				chat("The command " .. cmd.Name .. " is currently disabled. Please request it to be re-enabled by " .. bot.DisplayName .. ".")
				print("v3rBot CMDLogs // " .. speaker .. " attempted to run command: " .. cmd.Name .. " with arguments: " .. tts(args) .. "while the command was disabled.")
				return
			else
				cmd.CommandFunction(message, args, speaker)
				
				local function tts(t)
					local r = ""
					
					for i, v in pairs(t) do
						r = r .. v .. ", "
					end
					
					return r
				end
				
				print("v3rBot CMDLogs // " .. speaker .. " ran command: " .. cmd.Name .. " with arguments: " .. tts(args))
			end
		else
			warn("Could not find command: " .. args[1] .. "!")
		end
	elseif speakerplayer == copychatplayer then
		if altctrl then chat(message) else chat(speakerplayer.DisplayName .. ": " .. message) end
	end
end)

bot.Chatted:Connect(function(msg)
	if (string.lower(msg) == "v3rBot.disable()" or string.lower(msg) == "v3rBot.disconnect()") and disconnected == false then
		cmdcon:Disconnect()
		disconnected = true
		wait()
		chat("Successfully disconnected v3rBot.")
	end
end)

task.spawn(function()
	chat("v3rBot " .. v3rBotversion .. " // Loaded in " .. os.time() - bootTime .. " seconds!")
	wait(0.1)
	chat("You can now control this client! Type " .. prefix .. "cmds to view commands.")
end)

task.spawn(function()
	while wait(300) do
		if disconnected == false then
			chat("v3rBot is currently active! Type " .. prefix .. "cmds to view commands.")
		end
	end
end)

task.spawn(function()
	while wait(randommoveinteger) do
		if randommove == true and disconnected == false then
			local rndnum = math.random(1,4)
			local add = Vector3.new(0,0,0)
			
			if rndnum == 1 then
				add = Vector3.new(15,0,0)
			elseif rndnum == 2 then
				add = Vector3.new(-15,0,0)
			elseif rndnum == 3 then
				add = Vector3.new(0,0,15)
			else
				add = Vector3.new(0,0,-15)
			end
			
			bot.Character.Humanoid:MoveTo(bot.Character.HumanoidRootPart.Position + add)
		end
	end
end)

task.spawn(function()
	while wait() do
		if followplr and disconnected == false then
			local hum = bot.Character.Humanoid
			
			if hum then
				hum:MoveTo(followplr.Character.HumanoidRootPart.Position)		
			end
		end
	end
end)

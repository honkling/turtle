local Client = require "discord"
local Embed = require "embed"

local client = Client:create {}

if client == nil then
    print("Failed to create the client.")
    return
end

local commands = {}
for _, file in pairs(fs.list("/discord/commands")) do
    local name = string.sub(string.lower(file), 1, #file - 4)
    commands[name] = require ("/discord/commands/" .. name)
end

client:on("MESSAGE_CREATE", function (e)
    local data = e["d"]
    local content = data["content"]

    if string.find(content, "^!") == nil then
        return
    end

    content = string.sub(content, 2)
    local command = string.match(content, "^[^ ]+")
    local args = {}
    content = string.sub(content, #command + 2)

    for str in string.gmatch(content, "[^ ]+") do
        args[#args+1] = str
    end

    local channel = nil

    for _, guild in pairs(client.guilds) do
        guild = client:fetchGuild(guild.id)

        channel = guild.channels[data["channel_id"]]

        if channel ~= nil then
            break
        end
    end

    if channel == nil then
        error("Failed to find channel message was posted in?")
        return
    end

    if commands[command] == nil then
        return
    end

    local fn = commands[command]
    fn(channel, args)
end)

client:login("token")

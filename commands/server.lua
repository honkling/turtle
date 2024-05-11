local Embed = require "embed"
local json = require "json"

function server(channel, args)
    local name = args[1]

    local request = http.get(string.format("https://api.minehut.com/server/%s?byName=true", name))
    local response = json.decode(request.readAll()).server
    request.close()

    local visibility = "Public"
    if response.visibility ~= true then visibility = "Unlisted" end

    local color = 0x55FF55
    if response.online ~= true then color = 0xFF5555 end

    channel.send({ embeds = {
        Embed:create({})
            :setTitle(string.format("%s (%s)", response.name, visibility))
            :setDescription(string.format("```\n%s\n```", response.motd))
            :setColor(color)
            :setFooter("Requested by todo")
    } })
end

return server

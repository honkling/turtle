local ChannelType = require "channel_type"
local json        = require "json"

Channel = {
    client = nil,
    guild = nil,
    id = nil,
    type = nil,
    name = nil,
    topic = nil,
    nsfw = nil,
    parent = nil
}

function Channel:create(o)
    setmetatable(o, {__index = Channel})

    return o
end

function Channel:send(options)
    local acceptableTypes = {
        [ChannelType.DM] = true,
        [ChannelType.GROUP_DM] = true,
        [ChannelType.GUILD_ANNOUNCEMENT] = true,
        [ChannelType.GUILD_TEXT] = true,
        [ChannelType.PRIVATE_THREAD] = true,
        [ChannelType.PUBLIC_THREAD] = true
    }

    print(json.encode(self))
    print(self.type)
    print(acceptableTypes[self.type])

    if acceptableTypes[self.type] ~= true then
        error("Tried to send message in non-text channel")
        return
    end

    local content = options["content"]
    local embeds = options["embeds"]

    for i, embed in pairs(embeds) do
        embeds[i] = embed:toJSON()
    end

    self.client:post(string.format("/channels/%s/messages", self.id), {}, {
        content = content,
        embeds = embeds
    })
end

return Channel

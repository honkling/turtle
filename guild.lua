local ChannelType = require "channel_type"
local Channel = require "channel"

Guild = {
    unavailable = false,
    client = nil,
    id = nil,
    name = nil,
    owner = nil,
    roles = {},
    emojis = {},
    channels = {}
}

function Guild:create(o)
    setmetatable(o, {__index = Guild})

    o:fetchChannels()

    return o
end

function Guild:fetchChannels()
    local response = self.client:get(string.format("/guilds/%s/channels", self.id))

    for _, v in pairs(response) do
        self.channels[v.id] = Channel:create {
            client = self.client,
            guild = self,
            id = v.id,
            name = v.name,
            nsfw = v.nsfw,
            parent = v.parent_id,
            topic = v.topic,
            type = v.type
        }
    end

    for _, v in pairs(self.channels) do
        local function loop()
            if v.parent == nil then
                return
            end

            v.parent = self.channels[v.parent]
        end

        loop()
    end
end

return Guild

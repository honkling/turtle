local json = require "json"

Embed = {
    title = nil,
    description = nil,
    url = nil,
    timestamp = nil,
    color = nil,
    footer = nil,
    image = nil,
    thumbnail = nil,
    video = nil,
    provider = nil,
    author = nil,
    fields = {}
}

function Embed:create(o)
    setmetatable(o, {__index = Embed})

    return o
end

function Embed:setTitle(title)
    self.title = title
    return self
end

function Embed:setDescription(description)
    self.description = description
    return self
end

function Embed:setURL(url)
    self.url = url
    return self
end

function Embed:setTimestamp(timestamp)
    local regex = "^(\\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d\\.\\d+)|(\\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d)|(\\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d)$"

    if string.find(timestamp, regex) == nil then
        warn("Invalid timestamp provided: " .. timestamp)
        return self
    end

    self.timestamp = timestamp
    return self
end

function Embed:setColor(color)
    self.color = color
    return self
end

function Embed:setFooter(text, icon_url)
    self.footer = {
        text = text,
        icon_url = icon_url
    }
    return self
end

function Embed:setImage(url, width, height)
    self.image = {
        url = url,
        width = width,
        height = height
    }
    return self
end

function Embed:setThumbnail(url, width, height)
    self.thumbnail = {
        url = url,
        width = width,
        height = height
    }
    return self
end

function Embed:setVideo(url, width, height)
    self.video = {
        url = url,
        width = width,
        height = height
    }
    return self
end

function Embed:setProvider(name, url)
    self.provider = {
        name = name,
        url = url
    }
    return self
end

function Embed:setAuthor(name, url, icon_url)
    self.author = {
        name = name,
        url = url,
        icon_url = icon_url
    }
    return self
end

function Embed:addField(name, value, inline)
    if inline == nil then
        inline = false
    end

    self.fields[#self.fields+1] = {
        name = name,
        value = value,
        inline = inline
    }

    return self
end

function Embed:toJSON()
    local embed = {}

    for k, v in pairs(self) do
        if type(v) ~= "function" then
            embed[k] = v
        end
    end

    return embed
end

return Embed

local json = require "json"

local url = _ENV.arg[1]
local listing = http.get(url)
local toDownload = json.decode(listing.readAll())
listing.close()

for i = 1, #toDownload do
    local path = toDownload[i]
    local request = http.get(string.format("%s/%s", url, path))
    local content = request.readAll()
    request.close()

    local file = fs.open(string.format("/discord/%s.lua", path), "w")
    file.write(content)
    file.close()

    print(string.format("Downloaded %s.lua", path))
end

print("Done!")

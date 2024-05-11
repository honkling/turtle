local Guild = require "guild"
local json = require "json"

--local url = "gateway.discord.gg/?v=10&encoding=json"
local url = "6.tcp.ngrok.io:19374"

Client = {
	ws = nil,
	user = {
		id = nil,
		username = nil,
		discriminator = nil,
		global_name = nil,
		avatar = nil,
		bot = nil,
		mfa_enabled = nil,
		verified = true,
		email = nil
	},
	guilds = {},
	events = {},
	url = "https://discord.com/api/v9"
}

function Client:create(o)
	setmetatable(o, {__index = Client})

	self.ws = http.websocket("ws://" .. url)

	if self.ws == false then
		error("Failed to connect to Discord! Did you forget to change the ngrok URL?")
		return
	end

	return o
end

function Client:get(url, headers)
	if headers == nil then
		headers = {}
	end

	local ourHeaders = {
		authorization = "Bot " .. self.token
	}

	for i, v in pairs(ourHeaders) do
		headers[i] = v
	end

	local request, msg, err = http.get(string.format("%s%s", self.url, url), headers)

	if request == nil then
		if err ~= nil then
			print("Failed request: " .. err.getResponseCode())
			print(err.readAll())
			return nil
		end

		print("Failed request: " .. msg)
		return nil
	end

	local response = json.decode(request.readAll())
	request.close()

	return response
end

function Client:post(url, headers, body)
	if headers == nil then
		headers = {}
	end

	local ourHeaders = {
		["Content-Type"] = "application/json",
		authorization = "Bot " .. self.token
	}

	for i, v in pairs(ourHeaders) do
		headers[i] = v
	end

	local request, msg, err = http.post(string.format("%s%s", self.url, url), json.encode(body), headers)

	if request == nil then
		if err ~= nil then
			print("Failed request: " .. err.getResponseCode())
			print(err.readAll())
			return nil
		end

		print("Failed request: " .. msg)
		return nil
	end

	local response = json.decode(request.readAll())
	request.close()

	return response
end

function Client:login(token)
	self.token = token

	while true do
		local recv_data = self.ws.receive()

		if (recv_data == nil) then
			print("Socket closed or timed out.")
			break
		end

		local data = json.decode(recv_data)

		self:switch {
			[0] = function ()
				self:switch {
					["READY"] = function ()
						local d = data.d
						self.user = d.user

						for _, guild in pairs(d.guilds) do
							self.guilds[guild.id] = { unavailable = true, id = guild.id }
						end

						print(string.format("Logged in as %s#%s", self.user.username, self.user.discriminator))
					end,
					["GUILD_CREATE"] = function ()
						local guild = data.d

						self.guilds[guild.id] = self:constructGuild(guild)
					end,
					["CHANNEL_CREATE"] = function ()
					end
				}:case(data.t)

				local events = self.events[data.t]

				if events == nil then
					return
				end

				for _, cb in pairs(events) do
					cb(data)
				end
			end,
			[10] = function ()
				self:send({
					op = 2,
					d = {
						token = token,
						properties = {
							os = "linux",
							browser = "cctweaked",
							device = "cctweaked"
						},
						intents = 33281
					}
				})
			end,
			[11] = function () end,
			default = function () print("Unexpected type " .. data.op) end
		}:case(data.op)
	end
end

function Client:fetchGuild(id, force)
	if force == nil then
		force = false
	end

	local guild = self.guilds[id]

	if guild ~= nil and guild.unavailable ~= true and force ~= true then
		return guild
	end

	local response = self:get(string.format("/guilds/%s", id))
	guild = self:constructGuild(response)
	self.guilds[id] = guild
	return guild
end

function Client:constructGuild(response)
	return Guild:create {
		client = self,
		id = response.id,
		name = response.name,
		owner = response.owner_id
	}
end

function Client:send(data)
	self.ws.send(json.encode(data))
end

function Client:switch(t)
	t.case = function (self, x)
		local f = self[x] or self.default
		if f then
			if type(f) == "function" then
				f(x, self)
			else
				error("case " .. tostring(x) .. " not a function")
			end
		end
	end
	return t
end

function Client:on(event, cb)
	if self.events[event] == nil then
		self.events[event] = {}
	end

	self.events[event][#self.events[event]+1] = cb
end

return Client

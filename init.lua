local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local GROUP_ID
local INPUT_NAME
local VERBOSE = false

function log(...)
	if VERBOSE then
		print(...)
	end
end

if process.args[1] then
	INPUT_NAME = process.args[1]
else
	error("No input file specified.")
end

for index, arg in process.args do
	if arg == "-g" or arg == "--group" then
		GROUP_ID = process.args[index + 1]
	elseif arg == "-v" or arg == "--verbose" then
		VERBOSE = true
	end
end

if not INPUT_NAME then
	error("No input file specified. Specify one using --input <file>")
end

if GROUP_ID and not tonumber(GROUP_ID) then
	error("Group ID specified, but it's not a number.")
end

local input = fs.readFile(INPUT_NAME)
local deser = roblox.deserializeModel(input)[1]

local URL = "https://www.roblox.com/ide/publish/uploadnewanimation"
local COOKIE = roblox.getAuthCookie()

log("Getting CSRF token")

local getCSRF = net.request({
	url = URL,
	method = "POST",
	headers = {
		["Cookie"] = COOKIE,
		["Content-Type"] = "application/xml",
	},
})

local csrf = getCSRF.headers["x-csrf-token"]
if not csrf then
	error("Wasn't able to get CSRF token")
end

log(`CSRF token: {csrf}`)

local output = ""

for _, anim in deser:GetChildren() do
	if anim.ClassName ~= "KeyframeSequence" then
		continue
	end

	log(`Uploading {anim.Name}`)
	local res = net.request({
		url = URL,
		method = "POST",
		headers = {
			["Cookie"] = COOKIE,
			["Content-Type"] = "application/xml",
			["User-Agent"] = "RobloxStudio/WinInet",
			["Requester"] = "Client",
			["X-CSRF-TOKEN"] = csrf,
		},
		query = {
			["assetTypeName"] = "animation",
			["name"] = anim.Name,
			["description"] = "Uploaded with bulk-animation-upload",
			["AllID"] = "1",
			["ispublic"] = "false",
			["allowComments"] = "false",
			["isGamesAsset"] = "false",
			["groupId"] = GROUP_ID,
		},
		body = input,
	})

	if not res.ok then
		error(`Failed to upload {anim.Name}: {res.statusCode} {res.statusMessage}`)
	end

	log(`Uploaded {anim.Name}`)

	output = `{output}{anim.Name}: {res.body}\n`
end

fs.writeFile("output.txt", output)

log("Results written to output.txt")

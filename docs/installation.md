---
sidebar_position: 2
---

# Installation

### Method 1 - Wally

1. Setup [Wally](https://wally.run/) by using `wally init`.
2. Add `howmanysmall/react-tree` as a dependency.

```toml
[dependencies]
ReactTree = "howmanysmall/react-tree@^1.0.0"
```

### Method #2 - HttpService

This method uses `HttpService` to install ReactTree.

1. In Roblox Studio, paste the following command into your command bar.
2. Run the following command:

<textarea readonly rows="5" onClick={e => e.target.select()} style={{
   width: "100%"
}}>
   {`local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local HttpEnabled = HttpService.HttpEnabled
local REPOSITORY_NAME = "ReactTree"
HttpService.HttpEnabled = true
local function RequestAsync(RequestDictionary)
	return HttpService:RequestAsync(RequestDictionary)
end
local function GetAsync(Url, Headers)
	Headers["cache-control"] = "no-cache"
	local Success, ResponseDictionary = pcall(RequestAsync, {
		Headers = Headers;
		Method = "GET";
		Url = Url;
	})
	if Success then
		if ResponseDictionary.Success then
			return ResponseDictionary.Body
		else
			return false, string.format("HTTP %*: %*", ResponseDictionary.StatusCode, ResponseDictionary.StatusMessage)
		end
	else
		return false, ResponseDictionary
	end
end
local function Initify(Root)
	local InitFile = Root:FindFirstChild("init") or Root:FindFirstChild("init.lua") or Root:FindFirstChild("init.client.lua") or Root:FindFirstChild("init.server.lua")
	if InitFile then
		InitFile.Name = Root.Name
		InitFile.Parent = Root.Parent
		for _, Child in Root:GetChildren() do
			Child.Parent = InitFile
		end
		Root:Destroy()
		Root = InitFile
	end
	for _, Child in Root:GetChildren() do
		Initify(Child)
	end
	return Root
end
local FilesList = HttpService:JSONDecode(assert(GetAsync(
	string.format("https://api.github.com/repos/howmanysmall/%*/contents/src", REPOSITORY_NAME),
	{accept = "application/vnd.github.v3+json"}
)))
local Package = Instance.new("Folder")
Package.Name = REPOSITORY_NAME
for _, FileData in FilesList do
	local ModuleScript = Instance.new("ModuleScript")
	ModuleScript.Name = tostring(string.match(FileData.name, "(%w+)%.lua"))
	local Success, Source = GetAsync(FileData.download_url, {})
	if not Success then
		ModuleScript.Source = string.format("-- %*", tostring(Source))
	else
		ModuleScript.Source = tostring(Success)
	end
	ModuleScript.Parent = Package
end
Package.Parent = ReplicatedStorage
Initify(Package)
HttpService.HttpEnabled = HttpEnabled`}
</textarea>

## Next

Now, check out the [API reference](/api/ReactTree)!
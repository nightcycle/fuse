local fuse = script
local packages = fuse:WaitForChild("Packages")
local api = require(fuse:WaitForChild("API"))
local constructor = require(fuse:WaitForChild("Constructor"))

return function(inst)
	local source = ""
	for i, line in ipairs(constructor.new(inst)) do
		source = source.."\n"..line
	end
	local moduleScript = Instance.new("ModuleScript", game.ReplicatedStorage)
	moduleScript.Source = source
	moduleScript.Name = inst.Name
	return moduleScript
end
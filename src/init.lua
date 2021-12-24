local fuse = script
local api = require(fuse:WaitForChild("API"))
local constructor = require(fuse:WaitForChild("Constructor"))

return function(inst)
	local source = "local fusion = require(game.ReplicatedStorage.Packages.fusion)"
	source = source.."\nlocal synthetic = require(game.ReplicatedStorage.Packages.synthetic)"
	for i, line in ipairs(constructor.new(inst)) do
		source = source.."\n"..line
	end
	source = string.sub(source, 1, string.len(source)-1) --removes final comma
	local moduleScript = Instance.new("ModuleScript", game.ReplicatedStorage)
	moduleScript.Source = source
	moduleScript.Name = inst.Name
	return moduleScript
end
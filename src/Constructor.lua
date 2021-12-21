local packages = game.ReplicatedStorage:WaitForChild("Packages")
local fusion = require(packages:WaitForChild("fusion"))
local fuse = game.ReplicatedStorage:WaitForChild("fuse")
local api = require(fuse:WaitForChild("API"))

local constructor = {}
function constructor.new(inst)
	local className = inst.ClassName
	for i, propTabl in ipairs(api:GetPropertiesRaw(className)) do

	end
	return
end

return constructor
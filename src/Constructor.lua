local packages = game.ReplicatedStorage:WaitForChild("Packages")
local fuse = script.Parent
local api = require(fuse:WaitForChild("API"))

local lines = {}

local constructor = {}
local imports = {}
function constructor.new(inst, indentCount)
	if not indentCount then indentCount = 0 end
	local className = inst.ClassName
	local config = {}
	if not imports[className] then
		imports[className] = {}
		for i, propName in ipairs(api:GetPropertyList(className)) do
			imports[className][propName] = true
		end
	end
	for k, _ in pairs(imports[className]) do
		config[k] = inst[k]
	end
	if inst:GetAttribute("SynthClass") ~= nil then
		for k, v in pairs(inst:GetAttributes()) do
			if k ~= "SynthClass" then
				config[k] = v
			end
		end
		table.insert(lines, "synthetic '"..inst.Name.."' {")
	else
		table.insert(lines, "fusion.New '"..inst.Name.."' {")
	end

	for k, v in pairs(config) do
		local valConstructor = ""
		if type(v) == "userdata" then
			local constructorType = typeof(v)
			valConstructor = constructorType..".new('"..tostring(v).."')"
		else
			valConstructor = tostring(v)
		end
		table.insert(lines, "\t"..k.." = "..valConstructor)
	end
	table.insert(lines, "\t[fusion.Children] = {")
	for i, child in ipairs(inst:GetChildren()) do
		local childLines = constructor.new(inst, indentCount+2)
		for j, childLine in ipairs(childLines) do
			table.insert(lines, childLine)
		end
		lines[#lines] = lines[#lines]..","
	end
	table.insert(lines, "\t},")
	table.insert(lines, "},")

	for i, line in ipairs(lines) do
		lines[i] = string.rep("/t", indentCount)..line
	end

	return lines
end

return constructor
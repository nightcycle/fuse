
local packages = game.ReplicatedStorage.Packages
local fusionDefaults = require(packages:FindFirstChild("defaultProps", true))
local fuse = script.Parent
local api = require(fuse:WaitForChild("API"))

local constructor = {}
local imports = {}
function constructor.new(inst)
	if inst:IsA("Script") then return {} end
	local lines = {}

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
	local defaults = {}
	local robloxDefault = Instance.new(inst.ClassName)

	if inst:GetAttribute("SynthClass") ~= nil then
		for k, v in pairs(inst:GetAttributes()) do
			if k ~= "SynthClass" then
				config[k] = v
			end
		end
		table.insert(lines, "synthetic '"..inst:GetAttribute("SynthClass").."' {")
	else
		table.insert(lines, "fusion.New '"..inst.ClassName.."' {")
		defaults = fusionDefaults[inst.ClassName] or {}
	end

	for k, v in pairs(config) do
		if typeof(v) == "NumberSequence" or typeof(v) == "ColorSequence" then
			table.insert(lines, "\t"..k.." = "..typeof(v)..".new({")
			for index, keypoint in ipairs(v.Keypoints) do
				if typeof(keypoint.Value) ~= "Color3" then
					table.insert(lines, "\t\t"..typeof(v).."Keypoint.new("..keypoint.Time..", "..keypoint.Value.."),")
				else
					table.insert(lines, "\t\t"..typeof(v).."Keypoint.new("..keypoint.Time..", Color3.new("..tostring(keypoint.Value)..")".."),")
				end
			end
			table.insert(lines, "\t}),")
		elseif k ~= "Parent" then
			local valConstructor = ""
			if type(v) == "userdata" then
				local constructorType = typeof(v)
				if constructorType == "EnumItem" then
					valConstructor = tostring(v)
				elseif constructorType == "UDim2" then
					valConstructor = "UDim2.new("..tostring(math.round(1000*v.X.Scale)/1000)..","..tostring(math.round(v.X.Offset))..","..tostring(math.round(1000*v.Y.Scale)/1000)..","..tostring(math.round(v.Y.Offset))..")"
				elseif constructorType == "UDim" then
					valConstructor = "UDim.new("..tostring(math.round(1000*v.Scale)/1000)..","..tostring(math.round(v.Offset))..")"
				elseif constructorType == "Vector2"
					or constructorType == "Color3"
					or constructorType == "Rect"
					or constructorType == "Vector3" then

					if tostring(v) == "INF, INF" then
						valConstructor = constructorType..".new(math.huge, math.huge)"
					elseif tostring(v) == "INF, INF, INF" then
						valConstructor = constructorType..".new(math.huge, math.huge, math.huge)"
					else
						valConstructor = constructorType..".new("..tostring(v)..")"
					end
				else
					valConstructor = constructorType..".new('"..tostring(v).."')"
				end
			elseif type(v) == "string" then
				valConstructor = "'"..tostring(v).."'"
			else
				valConstructor = tostring(v)
			end
			if v ~= fusionDefaults[k] and v ~= robloxDefault[k] then
				table.insert(lines, "\t"..k.." = "..valConstructor..",")
			end
		end
	end
	robloxDefault:Destroy()

	if #inst:GetChildren() > 0 then
		table.insert(lines, "\t[fusion.Children] = {")
		for i, child in ipairs(inst:GetChildren()) do
			local childLines = constructor.new(child)
			for j, childLine in ipairs(childLines) do
				table.insert(lines, "\t\t"..childLine)
			end

		end
		table.insert(lines, "\t},")
	end
	table.insert(lines, "},")
	return lines
end

return constructor
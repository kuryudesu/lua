local PathIndicator = {}

local SPACING = 4
local IMAGE_URL = "rbxassetid://9133703399" 
local IMAGE_SIZE = Vector2.new(3, 3)
local IMAGE_COLOR = Color3.fromRGB(0, 255, 127) 
local POOL_SIZE = 50 

local player = game:GetService("Players").LocalPlayer
local workspace = game:GetService("Workspace")

local displayModel = Instance.new("Model")
displayModel.Name = "PathIndicatorModel"
displayModel.Parent = workspace

local adorneePart = Instance.new("Part")
adorneePart.Name = "PathAdornee"
adorneePart.Size = Vector3.new(1, 1, 1)
adorneePart.Transparency = 1
adorneePart.Anchored = true
adorneePart.CanCollide = false
adorneePart.Parent = displayModel

local imagePool = {} 
local activeImages = {} 


for i = 1, POOL_SIZE do
	local image = Instance.new("ImageHandleAdornment")
	image.Adornee = adorneePart
	image.Image = IMAGE_URL
	image.Size = IMAGE_SIZE
	image.Color3 = IMAGE_COLOR
	image.AlwaysOnTop = true
	image.Parent = nil
	table.insert(imagePool, image)
end


local function getImage()
	if #imagePool > 0 then
		return table.remove(imagePool, 1)
	end
	return nil 
end


local function returnImage(image)
	if image then
		image.Parent = nil
		table.insert(imagePool, image)
	end
end


local function renderPoint(position)
	local image = getImage()
	if not image then return end
	
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {player.Character, displayModel}

	local rayOrigin = position + Vector3.new(0, 50, 0)
	local rayDirection = Vector3.new(0, -100, 0)
	
	local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
	
	if result and result.Position then
		local groundPosition = result.Position
        local surfaceNormal = result.Normal

        -- ⭐ 1. 增加抬升高度，讓它更明顯
        local offsetAmount = 4.5 -- 將抬升高度增加到 1.0，你可以根據需要調整
        local finalPosition = groundPosition + (surfaceNormal * offsetAmount)
        
        -- ⭐ 2. 使用 CFrame.lookAt 來確保方向正確
        -- 第一個參數是圖片的位置 (finalPosition)
        -- 第二個參數是圖片要"看向"的位置。讓它看向 "位置 + 法線方向"
        -- 這樣圖片的正面就會總是朝外，與地面垂直。
        image.CFrame = CFrame.lookAt(finalPosition, finalPosition + surfaceNormal)
        
		image.Parent = displayModel
		table.insert(activeImages, image)


        local debugSphere = Instance.new("Part")
        debugSphere.Name = "DebugSphere"
        debugSphere.Shape = Enum.PartType.Ball
        debugSphere.Material = Enum.Material.Neon
        debugSphere.Color = Color3.fromRGB(255, 0, 0)
        debugSphere.Size = Vector3.new(1, 1, 1)
        debugSphere.Anchored = true
        debugSphere.CanCollide = false
        debugSphere.Position = finalPosition
        debugSphere.Parent = workspace
        game.Debris:AddItem(debugSphere, 5) -- 5秒後自動刪除
        --]]
        
	else
		returnImage(image)
	end
end

function PathIndicator.clear()
	for _, image in ipairs(activeImages) do
		returnImage(image)
	end
	activeImages = {}
end


function PathIndicator.render(waypoints)
	PathIndicator.clear()

	if not waypoints or #waypoints < 2 then
		return 
	end

	displayModel.Parent = workspace 
	
	for i = 1, #waypoints - 1 do
		local startPoint = waypoints[i].Position
		local endPoint = waypoints[i+1].Position
		local segmentVector = endPoint - startPoint
		local segmentLength = segmentVector.Magnitude
		
		renderPoint(startPoint)


		if segmentLength > SPACING then
			local numPointsToInsert = math.floor(segmentLength / SPACING)
			for j = 1, numPointsToInsert do
				local interpolatedPosition = startPoint + (segmentVector.Unit * SPACING * j)
				renderPoint(interpolatedPosition)
			end
		end
	end

	renderPoint(waypoints[#waypoints].Position)
end

return PathIndicator

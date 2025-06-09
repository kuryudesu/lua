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
	if not image then
		print("PathIndicator Debug: Image pool is empty!") -- Debug 訊息
		return
	end
	
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {player.Character, displayModel}

	local rayOrigin = position + Vector3.new(0, 10, 0)
	local rayDirection = Vector3.new(0, -20, 0)
	
	local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
	
	if result and result.Position then
		
		print("PathIndicator Debug: Rendering point at", result.Position)
		
		image.CFrame = CFrame.new(result.Position)
		image.Parent = displayModel -- ⭐ 確保這裡不是 adorneePart
		table.insert(activeImages, image)
	else
		
		print("PathIndicator Debug: Raycast from", rayOrigin, "missed the ground.") -- Debug 訊息
		returnImage(image)
	end
end

return PathIndicator

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
        local offsetAmount = 10.0
        local finalPosition = groundPosition + (surfaceNormal * offsetAmount)
        

        local worldUp = Vector3.new(0, 1, 0)
        

        local rightVector = surfaceNormal:Cross(worldUp)


        if rightVector.Magnitude < 0.01 then
            rightVector = Vector3.new(1, 0, 0)
        end
        

        local lookVector = surfaceNormal:Cross(rightVector)


        image.CFrame = CFrame.new(
            finalPosition.X, finalPosition.Y, finalPosition.Z,
            rightVector.X, surfaceNormal.X, -lookVector.X,
            rightVector.Y, surfaceNormal.Y, -lookVector.Y,
            rightVector.Z, surfaceNormal.Z, -lookVector.Z
        )
        
		image.Parent = displayModel
		table.insert(activeImages, image)
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

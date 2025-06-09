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
	return nil -- 池已空
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

	local rayOrigin = position + Vector3.new(0, 10, 0)
	local rayDirection = Vector3.new(0, -20, 0)
	
	local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
	
	if result and result.Position then
		image.CFrame = CFrame.new(result.Position)
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
	displayModel.Parent = nil
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

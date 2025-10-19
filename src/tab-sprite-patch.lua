-- Sprite icon handling code to add after "image" type
elseif iconType == "sprite" then
	-- Create sprite sheet icon (Lucide)
	tabIcon = Instance.new("ImageLabel")
	tabIcon.BackgroundTransparency = 1
	tabIcon.Image = "rbxassetid://" .. iconAsset.id
	tabIcon.ImageRectSize = iconAsset.imageRectSize
	tabIcon.ImageRectOffset = iconAsset.imageRectOffset
	tabIcon.Size = UDim2.new(0, 28, 0, 28)
	tabIcon.Position = UDim2.new(0.5, -14, 0.5, -14)
	tabIcon.ImageColor3 = pal2.TextSub
	tabIcon.Parent = tabBtn

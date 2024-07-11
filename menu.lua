local plr = game.Players.LocalPlayer

local menu = Instance.new('ScreenGui')
menu.Name = "v3rMenu"
menu.Parent = plr.PlayerGui

local UIframe = Instance.new('Frame')
UIframe.Parent = menu
UIframe.AnchorPoint = Vector2.new(0.5, 0.5)
UIframe.Position = UDim2.new(0.5,0,0.5,0)
UIframe.Size = UDim2.new(0, 500, 0, 350)
local UICorner = Instance.new('UICorner')
UICorner.Parent = UIframe
UICorner.CornerRadius = UDim.new(0, 25)

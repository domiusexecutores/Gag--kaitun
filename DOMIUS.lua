-- 🌟 FPS BOOST
print("🔧 FPS Boost ativado")
local Lighting = game:GetService("Lighting")
Lighting.GlobalShadows = false
Lighting.FogEnd = 100
Lighting.Brightness = 0
for _, v in pairs(workspace:GetDescendants()) do
	if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
		v.Enabled = false
	elseif v:IsA("Explosion") then
		v.Visible = false
	elseif v:IsA("Decal") then
		v.Transparency = 1
	elseif v:IsA("BasePart") then
		v.Material = Enum.Material.Plastic
		v.Reflectance = 0
	end
end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function stripCharacter(char)
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("Accessory") or part:IsA("Shirt") or part:IsA("Pants") or part:IsA("CharacterMesh") then
			part:Destroy()
		elseif part:IsA("Decal") then
			part.Transparency = 1
		end
	end
end
if LocalPlayer.Character then stripCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart")
	task.wait(0.5)
	stripCharacter(char)
end)
if workspace:FindFirstChildOfClass("Terrain") then
	workspace.Terrain.WaterWaveSize = 0
	workspace.Terrain.WaterWaveSpeed = 0
	workspace.Terrain.WaterReflectance = 0
	workspace.Terrain.WaterTransparency = 1
end
for _, v in pairs(Lighting:GetChildren()) do
	if v:IsA("PostEffect") then
		v.Enabled = false
	end
end
pcall(function()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)
print("✅ FPS Boost aplicado com sucesso!")

-- 🧾 Interface GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DomiusInterface"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local title = Instance.new("TextLabel")
title.Text = "Apple Hub  (🏖️☀️)"
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = screenGui

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 0, 25)
timerLabel.Position = UDim2.new(0, 0, 0, 35)
timerLabel.BackgroundTransparency = 1
timerLabel.TextColor3 = Color3.fromRGB(173, 216, 230)
timerLabel.Font = Enum.Font.Gotham
timerLabel.TextScaled = true
timerLabel.Text = "Timer: 00:00m"
timerLabel.Parent = screenGui

local seconds = 0
game:GetService("RunService").RenderStepped:Connect(function(delta)
	seconds += delta
	local totalSeconds = math.floor(seconds)
	local minutes = math.floor(totalSeconds / 60)
	local hours = math.floor(minutes / 60)
	local display = ""
	if hours >= 1 then
		display = string.format("Timer: %02d:%02dh", hours, minutes % 60)
	else
		display = string.format("Timer: %02d:%02dm", minutes, totalSeconds % 60)
	end
	timerLabel.Text = display
end)

local image = Instance.new("ImageLabel")
image.Image = "rbxassetid://132715149837734"
image.Size = UDim2.new(0, 100, 0, 100)
image.Position = UDim2.new(0.5, -50, 0.5, -50)
image.BackgroundTransparency = 1
image.ImageTransparency = 0.6
image.Parent = screenGui

-- 📥 Auto Buy Seeds
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local DataService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DataService"))
local FruitPrices = {
	["Carrot"] = 10, ["Blueberry"] = 400, ["Cauliflower"] = 1300,
	["Tomato"] = 800, ["Banana"] = 7000, ["Mango"] = 100000, ["Dragon Fruit"] = 60
}
local function findOriginalMoneyLabel()
	local moneyGui = PlayerGui:FindFirstChild("Sheckles_UI") or PlayerGui:FindFirstChild("MoneyGui")
	if not moneyGui then
		for _, guiObj in pairs(PlayerGui:GetChildren()) do
			if guiObj:IsA("ScreenGui") then
				for _, desc in pairs(guiObj:GetDescendants()) do
					if desc:IsA("TextLabel") and desc.Text:match("%d") then
						return desc
					end
				end
			end
		end
	end
	if moneyGui then
		for _, desc in pairs(moneyGui:GetDescendants()) do
			if desc:IsA("TextLabel") and desc.Text:match("%d") then
				return desc
			end
		end
	end
	return nil
end
local function parseMoney(text)
	local clean = text:gsub("[^%d]", "")
	return tonumber(clean) or 0
end
task.spawn(function()
	while true do
		task.wait(0)
		local moneyLabel = findOriginalMoneyLabel()
		if not moneyLabel then continue end
		local money = parseMoney(moneyLabel.Text)
		if money <= 0 then continue end
		local data = DataService:GetData()
		local seedStock = data["SeedStock"]["Stocks"]
		local candidates = {}
		for fruitName, price in pairs(FruitPrices) do
			local fruit = seedStock[fruitName]
			if fruit and fruit.Stock > 0 and money >= price then
				table.insert(candidates, {name = fruitName, price = price})
			end
		end
		table.sort(candidates, function(a, b) return a.price < b.price end)
		if #candidates > 0 then
			local chosen = candidates[1]
			print("Comprando:", chosen.name)
			ReplicatedStorage.GameEvents.BuySeedStock:FireServer(chosen.name)
		end
	end
end)

-- 🌾 Auto Plant
local MyFarm
for _, v in pairs(workspace.Farm:GetChildren()) do
	if v.Name == "Farm" and v:FindFirstChild("Important") then
		if v.Important.Data.Owner.Value == LocalPlayer.Name then
			MyFarm = v
			break
		end
	end
end
local function randompt(part)
	local size = part.Size
	local localX = (math.random() - 0.5) * size.X
	local localY = (math.random() - 0.5) * size.Y
	local localZ = (math.random() - 0.5) * size.Z
	local offset = Vector3.new(localX, localY, localZ)
	local pos = part.CFrame:PointToWorldSpace(offset)
	local rot = CFrame.Angles(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), math.rad(math.random(0, 360)))
	return CFrame.new(pos) * rot
end
local function cleanSeedName(name)
	local stripped = name:gsub("%A+%[(.-)%]", "")
	return stripped:gsub(" Seed", "")
end
local function checkHasSeed()
	for _, v in pairs(LocalPlayer.Character:GetChildren()) do
		if v:IsA("Tool") and v.Name:lower():find("seed") then return v end
	end
	for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") and v.Name:lower():find("seed") then return v end
	end
	return nil
end
local function plantSeed(seedTool)
	if not MyFarm or not seedTool then return end
	if seedTool.Parent == LocalPlayer.Backpack then
		LocalPlayer.Character.Humanoid:EquipTool(seedTool)
		task.wait(0.3)
	end
	local locations = MyFarm.Important.Plant_Locations:GetChildren()
	if #locations == 0 then return end
	local part = locations[math.random(1, #locations)]
	local cf = randompt(part)
	local seedName = cleanSeedName(seedTool.Name)
	LocalPlayer.Character.HumanoidRootPart.CFrame = cf * CFrame.new(0, 10, 0)
	task.wait(0.15)
	ReplicatedStorage.GameEvents.Plant_RE:FireServer(Vector3.new(cf.X, cf.Y, cf.Z), seedName)
end
getgenv().AutoPlant = true
task.spawn(function()
	while getgenv().AutoPlant do
		local seed = checkHasSeed()
		if seed then plantSeed(seed) end
		task.wait(0.0)
	end
end)

-- 🌾 Auto Collect + Venda
getgenv().AutoCollect = true
getgenv().CollectLimit = 4
local CollectionService = game:GetService("CollectionService")
local Remotes = require(ReplicatedStorage.Modules.Remotes)
local CollectRemote = Remotes.Crops.Collect
local function getcrop()
	local colhidos = {}
	for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
		if not item.Name:lower():find("seed") and not item.Name:lower():find("shovel") then
			table.insert(colhidos, item)
		end
	end
	return colhidos
end
local function getColetaveis()
	local prontos = CollectionService:GetTagged("CollectPrompt")
	local meus = {}
	for _, obj in pairs(prontos) do
		local important = obj:FindFirstAncestor("Important")
		if important and important:FindFirstChild("Data") and important.Data.Owner.Value == LocalPlayer.Name then
			table.insert(meus, obj.Parent.Parent)
		end
	end
	return meus
end
local function vender()
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = CFrame.new(86.8899384, 2.99999976, 0.119625024)
	end
	ReplicatedStorage.GameEvents.Sell_Inventory:FireServer()
end
task.spawn(function()
	while true do
		if not getgenv().AutoCollect then task.wait(0.5) continue end
		if checkHasSeed() then task.wait(0.5) continue end
		local mochila = getcrop()
		if #mochila >= getgenv().CollectLimit then
			vender()
		else
			local plantas = getColetaveis()
			if #plantas > 0 then
				for _, planta in pairs(plantas) do
					if checkHasSeed() or #getcrop() >= getgenv().CollectLimit then break end
					CollectRemote.send({ planta })
					task.wait(0.1)
				end
			elseif #mochila > 0 then
				vender()
			end
		end
		task.wait(0.2)
	end
end)
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- 🔧 Nomes das GUIs que NÃO devem ser removidas
local GUIsParaManter = {
	["DomiusInterface"] = true,
	["Sheckles_UI"] = true,
	["MoneyGui"] = true
}

-- 🖼️ Remove GUIs exceto as permitidas
for _, v in pairs(gui:GetChildren()) do
	if v:IsA("ScreenGui") or v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
		if not GUIsParaManter[v.Name] then
			v:Destroy()
		end
	end
end

-- 🔇 Remove sons da interface e ambiente
for _, sound in pairs(SoundService:GetDescendants()) do
	if sound:IsA("Sound") then
		sound:Stop()
		sound.Volume = 0
	end
end

-- 🔇 Sons do personagem
if player.Character then
	for _, sound in pairs(player.Character:GetDescendants()) do
		if sound:IsA("Sound") then
			sound:Stop()
			sound.Volume = 0
		end
	end
end

-- 💨 Desliga pós-processamento
for _, effect in pairs(Lighting:GetChildren()) do
	if effect:IsA("PostEffect") then
		effect.Enabled = false
	end
end

-- ☀️ Ajusta o Lighting para mais leve
Lighting.GlobalShadows = false
Lighting.FogEnd = 100
Lighting.Brightness = 0

-- 🔥 Desativa partículas e visuais inúteis
for _, v in pairs(workspace:GetDescendants()) do
	if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
		v.Enabled = false
	elseif v:IsA("Decal") then
		v.Transparency = 1
	end
end

-- 🌊 Desliga efeitos da água/terreno
if workspace:FindFirstChildOfClass("Terrain") then
	workspace.Terrain.WaterWaveSize = 0
	workspace.Terrain.WaterWaveSpeed = 0
	workspace.Terrain.WaterReflectance = 0
	workspace.Terrain.WaterTransparency = 1
end

-- ✅ Pronto
print("✅ Tela limpa com DomiusInterface e dinheiro mantidos.")
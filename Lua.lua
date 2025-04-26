-- Garden Game ESP & Fly Script
-- Features:
-- 1. ESP for objects with text filter (Toggle with K key)
-- 2. Fly with auto-noclip (Toggle with F key)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Settings
local Settings = {
    ESP = false,
    ESPFilter = "",
    ESPDistance = 30, -- Maximum ESP render distance
    Fly = false,
    FlySpeed = 5
}

-- Variables
local ESPObjects = {}
local Connections = {}

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GardenToolsGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 140)
MainFrame.Position = UDim2.new(0.85, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.9, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "Garden Tools"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Add X button for termination
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.Parent = MainFrame

local StatusFrame = Instance.new("Frame")
StatusFrame.Name = "StatusFrame"
StatusFrame.Size = UDim2.new(0.9, 0, 0.65, 0)
StatusFrame.Position = UDim2.new(0.5, 0, 0.58, 0)
StatusFrame.AnchorPoint = Vector2.new(0.5, 0.5)
StatusFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = MainFrame

-- Create status text for ESP
local ESPText = Instance.new("TextLabel")
ESPText.Name = "ESPStatus"
ESPText.Size = UDim2.new(0.95, 0, 0, 20)
ESPText.Position = UDim2.new(0.5, 0, 0, 10)
ESPText.AnchorPoint = Vector2.new(0.5, 0)
ESPText.BackgroundTransparency = 1
ESPText.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPText.Text = "ESP (K): OFF"
ESPText.Font = Enum.Font.SourceSans
ESPText.TextSize = 14
ESPText.TextXAlignment = Enum.TextXAlignment.Left
ESPText.Parent = StatusFrame

-- Create status text for Fly
local FlyText = Instance.new("TextLabel")
FlyText.Name = "FlyStatus"
FlyText.Size = UDim2.new(0.95, 0, 0, 20)
FlyText.Position = UDim2.new(0.5, 0, 0, 35)
FlyText.AnchorPoint = Vector2.new(0.5, 0)
FlyText.BackgroundTransparency = 1
FlyText.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyText.Text = "Fly (F): OFF"
FlyText.Font = Enum.Font.SourceSans
FlyText.TextSize = 14
FlyText.TextXAlignment = Enum.TextXAlignment.Left
FlyText.Parent = StatusFrame

-- Create filter input for ESP
local ESPFilterInput = Instance.new("TextBox")
ESPFilterInput.Name = "ESPFilterInput"
ESPFilterInput.Size = UDim2.new(0.95, 0, 0, 25)
ESPFilterInput.Position = UDim2.new(0.5, 0, 0, 65)
ESPFilterInput.AnchorPoint = Vector2.new(0.5, 0)
ESPFilterInput.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
ESPFilterInput.BorderSizePixel = 1
ESPFilterInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPFilterInput.PlaceholderText = "ESP Filter (leave empty for all plants)"
ESPFilterInput.Text = ""
ESPFilterInput.Font = Enum.Font.SourceSans
ESPFilterInput.TextSize = 14
ESPFilterInput.Parent = StatusFrame

-- Functions
local function UpdateStatusText()
    ESPText.Text = "ESP (K): " .. (Settings.ESP and "ON" or "OFF")
    ESPText.TextColor3 = Settings.ESP and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
    
    FlyText.Text = "Fly (F): " .. (Settings.Fly and "ON" or "OFF")
    FlyText.TextColor3 = Settings.Fly and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
end

-- Noclip function
local function SetNoclip(enabled)
    if not Character then return end
    
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = not enabled
        end
    end
end

-- ESP Functions
local function CreateESP(object)
    if ESPObjects[object] then return end
    
   local highlight = nil
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 100, 0, 20)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.Adornee = object:IsA("Model") and (object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")) or object
    billboardGui.AlwaysOnTop = true
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    textLabel.Text = object.Name
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 14
    textLabel.Parent = billboardGui
    
    billboardGui.Parent = object
    
 ESPObjects[object] = {highlight = nil, label = billboardGui}
end

local function RemoveESP(object)
    if ESPObjects[object] then
        if ESPObjects[object].label and ESPObjects[object].label.Parent then
            ESPObjects[object].label:Destroy()
        end
        ESPObjects[object] = nil
    end
end

local function ClearAllESP()
    for object, espData in pairs(ESPObjects) do
        if espData.label and espData.label.Parent then
            espData.label:Destroy()
        end
    end
    ESPObjects = {}
end

-- Check if object matches the filter
local function MatchesFilter(obj)
    if Settings.ESPFilter == "" then
        return true -- Empty filter matches everything
    end
    return obj.Name:lower():find(Settings.ESPFilter:lower())
end

local function UpdateESP()
    -- Don't update if ESP is off
    if not Settings.ESP then
        if next(ESPObjects) ~= nil then
            ClearAllESP() -- Clear ESP if it was previously on
        end
        return
    end
    
    -- Get player position for distance check
    local playerPos = HumanoidRootPart and HumanoidRootPart.Position or Vector3.new(0, 0, 0)
    
    -- Keep track of current objects to avoid removing and re-adding unnecessarily
    local currentObjects = {}
    
    -- Find objects to highlight, with distance limit
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Only check objects that match the filter
        if (obj:IsA("Model") or obj:IsA("BasePart")) and MatchesFilter(obj) then
            -- Check distance
            local objPosition
            if obj:IsA("Model") and obj.PrimaryPart then
                objPosition = obj.PrimaryPart.Position
            elseif obj:IsA("BasePart") then
                objPosition = obj.Position
            else
                local part = obj:FindFirstChildWhichIsA("BasePart")
                objPosition = part and part.Position or nil
            end
            
            if objPosition and (objPosition - playerPos).Magnitude <= Settings.ESPDistance then
                -- Add to current objects
                currentObjects[obj] = true
                
                -- Create ESP if not already there
                if not ESPObjects[obj] then
                    CreateESP(obj)
                end
            end
        end
    end
    
    -- Remove ESP from objects no longer in range or matching filter
    for obj, _ in pairs(ESPObjects) do
        if not currentObjects[obj] or not obj.Parent then
            RemoveESP(obj)
        end
    end
end

local function ToggleESP()
    Settings.ESP = not Settings.ESP
    UpdateStatusText()
    UpdateESP()
end

-- Fly Function
local FlyLoop = nil
local flyForce = nil

local function ToggleFly()
    Settings.Fly = not Settings.Fly
    UpdateStatusText()
    
    -- Clean up existing fly
    if FlyLoop then
        FlyLoop:Disconnect()
        FlyLoop = nil
    end
    
    if flyForce and flyForce.Parent then
        flyForce:Destroy()
        flyForce = nil
    end
    
    -- Enable noclip when flying
    SetNoclip(Settings.Fly)
    
    if Settings.Fly then
        -- Create a custom camera subject that won't be affected by objects
        local cameraSubject = Instance.new("Part")
        cameraSubject.Name = "FlyingCameraSubject"
        cameraSubject.Anchored = true
        cameraSubject.CanCollide = false
        cameraSubject.Transparency = 1
        cameraSubject.Size = Vector3.new(1, 1, 1)
        cameraSubject.CFrame = HumanoidRootPart.CFrame
        cameraSubject.Parent = workspace
        
        -- Set camera to use our custom part instead of the character
        workspace.CurrentCamera.CameraSubject = cameraSubject
        
        -- Disable gravity
        workspace.Gravity = 0
        
        -- Create fly force
        flyForce = Instance.new("BodyVelocity")
        flyForce.Name = "FlyForce"
        flyForce.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyForce.Velocity = Vector3.new(0, 0, 0)
        flyForce.Parent = HumanoidRootPart
        
        local ctrl = {f = 0, b = 0, l = 0, r = 0, q = 0, e = 0}
        
        FlyLoop = RunService.Heartbeat:Connect(function()
            if not Settings.Fly or not Character or not Character:FindFirstChild("HumanoidRootPart") then
                ToggleFly()
                return
            end
            
            -- Update camera subject position to follow character
            local cameraSubject = workspace:FindFirstChild("FlyingCameraSubject")
            if cameraSubject then
                cameraSubject.CFrame = HumanoidRootPart.CFrame
            end
            
            local speed = Settings.FlySpeed
            -- Disable humanoid states to prevent climbing
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

-- Check keyboard inputs for movement
local isShiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
local currentSpeed = isShiftPressed and speed * 1.5 or speed

ctrl.f = UserInputService:IsKeyDown(Enum.KeyCode.W) and currentSpeed or 0
ctrl.b = UserInputService:IsKeyDown(Enum.KeyCode.S) and -currentSpeed or 0
ctrl.l = UserInputService:IsKeyDown(Enum.KeyCode.A) and -currentSpeed or 0
ctrl.r = UserInputService:IsKeyDown(Enum.KeyCode.D) and currentSpeed or 0
ctrl.q = UserInputService:IsKeyDown(Enum.KeyCode.Space) and currentSpeed or 0
ctrl.e = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -currentSpeed or 0  -- Changed to Control for down


            -- Update velocity based on camera direction
            local camera = workspace.CurrentCamera
            local cameraDirection = camera.CFrame
            
            if ctrl.f + ctrl.b ~= 0 or ctrl.l + ctrl.r ~= 0 or ctrl.q + ctrl.e ~= 0 then
                local vel = (cameraDirection.lookVector * (ctrl.f + ctrl.b)) + 
                            (cameraDirection.rightVector * (ctrl.r + ctrl.l)) + 
                            (Vector3.new(0, 1, 0) * (ctrl.q + ctrl.e))
                
                flyForce.Velocity = vel * speed
            else
                flyForce.Velocity = Vector3.new(0, 0, 0)
            end
            
            -- Ensure noclip stays on
            SetNoclip(true)
        end)
        table.insert(Connections, FlyLoop)
    else
         -- Reset the camera subject back to the Humanoid
        local cameraSubject = workspace:FindFirstChild("FlyingCameraSubject")
        if cameraSubject then
           cameraSubject:Destroy()
        end
        workspace.CurrentCamera.CameraSubject = Humanoid
            -- Reset gravity
        workspace.Gravity = 196.2
    end
end

-- Function to terminate the script
local function TerminateScript()
    -- Clean up all ESP objects
    ClearAllESP()
    
    -- Disable fly if active
    if Settings.Fly then
        Settings.Fly = false
        if workspace.Gravity == 0 then
            workspace.Gravity = 196.2
        end
        if flyForce and flyForce.Parent then
            flyForce:Destroy()
        end
        SetNoclip(false)
    end
    
    -- Disconnect all connections
    for _, connection in pairs(Connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    
    -- Remove GUI
    ScreenGui:Destroy()
    
    -- Notify in console
    print("Garden Tools Script terminated!")
end

-- Connect filter input
ESPFilterInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        Settings.ESPFilter = ESPFilterInput.Text
        UpdateESP()
    end
end)

-- Connect X button to terminate
CloseButton.MouseButton1Click:Connect(function()
    TerminateScript()
end)

-- Input handling
local inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.K then
        ToggleESP()
    elseif input.KeyCode == Enum.KeyCode.F then
        ToggleFly()
    elseif input.KeyCode == Enum.KeyCode.End then
        -- Terminate script with End key
        TerminateScript()
    end
end)
table.insert(Connections, inputConnection)

-- Update ESP regularly
local updateConnection = RunService.Heartbeat:Connect(function()
    -- Update ESP at a reasonable rate to avoid lag
    if Settings.ESP and tick() % 4 < 0.01 then -- Update every 4 second (doubled)
        UpdateESP()
    end
    
    -- Make sure character parts are properly set
    if Character ~= LocalPlayer.Character then
        Character = LocalPlayer.Character
        if Character then
            Humanoid = Character:WaitForChild("Humanoid")
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            
            -- Re-enable fly if it was active
            if Settings.Fly then
                ToggleFly()
                ToggleFly()
            end
        end
    end
end)
table.insert(Connections, updateConnection)

-- Handle character respawn
local characterConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Re-enable fly if it was active
    if Settings.Fly then
        ToggleFly()
        ToggleFly()
    end
    
    -- Update ESP
    if Settings.ESP then
        UpdateESP()
    end
end)
table.insert(Connections, characterConnection)

-- Initial setup
UpdateStatusText()

-- Print instructions
print("Garden Tools Script loaded!")
print("Controls:")
print("- Toggle ESP: K (50 stud distance limit)")
print("- Toggle Fly: F (WASD to move, Space to go up, Shift to go down)")
print("- Filter Objects: Type in the text box and press Enter")
print("- Terminate Script: Press End key or click X button")
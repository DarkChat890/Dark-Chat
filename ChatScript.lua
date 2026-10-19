--[[
    ═══════════════════════════════════════════
    DARK CHAT V6 - OFFICIAL RELEASE
    ⭐ Chat UI chuẩn Roblox + Full Role + Admin Panel
    📌 Chỉ hiện người đang dùng script
    🔒 Admin Panel ẩn với Member
    ✅ Đã test kỹ, sẵn sàng chia sẻ
    ═══════════════════════════════════════════
--]]

--═══════════════════════════════════════════════════════════════════════════════
-- SERVICES
--═══════════════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--═══════════════════════════════════════════════════════════════════════════════
-- ROLE CONFIG
--═══════════════════════════════════════════════════════════════════════════════
local ROLE_CONFIG = {
    Owners = {
        ["hibro800000"] = true,     -- 👑 BẠN LÀ OWNER
    },
    Admins = {},
    Mods   = {},
    VIPs   = {}
}

local ROLE_STYLE = {
    Owner  = { Color = Color3.fromRGB(255, 215, 0),   Icon = "👑", Tag = "[OWNER]" },
    Admin  = { Color = Color3.fromRGB(255, 60, 60),   Icon = "🛡️", Tag = "[ADMIN]" },
    Mod    = { Color = Color3.fromRGB(255, 140, 0),   Icon = "🔨", Tag = "[MOD]"   },
    VIP    = { Color = Color3.fromRGB(100, 200, 255), Icon = "💎", Tag = "[VIP]"   },
    Member = { Color = Color3.fromRGB(200, 200, 200), Icon = "👤", Tag = ""        },
}

local function getRole(name)
    local l = string.lower(name)
    if ROLE_CONFIG.Owners[l] then return "Owner" end
    if ROLE_CONFIG.Admins[l] then return "Admin" end
    if ROLE_CONFIG.Mods[l]   then return "Mod"   end
    if ROLE_CONFIG.VIPs[l]   then return "VIP"   end
    return "Member"
end

local function hasAdminPower(name)
    local r = getRole(name)
    return r == "Owner" or r == "Admin" or r == "Mod"
end

local MY_ROLE = getRole(player.Name)
local MY_STYLE = ROLE_STYLE[MY_ROLE]
local I_AM_ADMIN = hasAdminPower(player.Name)

--═══════════════════════════════════════════════════════════════════════════════
-- DATABASE
--═══════════════════════════════════════════════════════════════════════════════
local BannedPlayers = _G.DarkChatBans or {}
local MutedPlayers  = _G.DarkChatMutes or {}

local function saveDB()
    _G.DarkChatBans = BannedPlayers
    _G.DarkChatMutes = MutedPlayers
end

local function isBanned(name)
    return BannedPlayers[string.lower(name)] ~= nil
end

local function isMuted(name)
    local m = MutedPlayers[string.lower(name)]
    if not m then return false, nil end
    if os.time() >= m.until then
        MutedPlayers[string.lower(name)] = nil
        saveDB()
        return false, nil
    end
    return true, m
end

--═══════════════════════════════════════════════════════════════════════════════
-- DANH SÁCH NGƯỜI DÙNG SCRIPT (chỉ những người đang execute)
--═══════════════════════════════════════════════════════════════════════════════
-- Vì là local UI, mỗi người tự có danh sách riêng.
-- Danh sách này bao gồm: chính bạn + bất kỳ ai trong game (để admin có thể ban)
-- Ta lưu tất cả player trong game để admin chọn
local function getActiveScriptUsers()
    local list = {}
    -- Thêm bản thân
    table.insert(list, {
        Name = player.Name,
        DisplayName = player.DisplayName,
        Role = MY_ROLE,
        IsSelf = true
    })
    -- Thêm player khác trong game (admin có thể ban/mute họ)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(list, {
                Name = p.Name,
                DisplayName = p.DisplayName,
                Role = getRole(p.Name),
                IsSelf = false
            })
        end
    end
    return list
end

--═══════════════════════════════════════════════════════════════════════════════
-- XÓA GUI CŨ
--═══════════════════════════════════════════════════════════════════════════════
local old = playerGui:FindFirstChild("DarkChatUI")
if old then old:Destroy() end

--═══════════════════════════════════════════════════════════════════════════════
-- SCREEN GUI
--═══════════════════════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DarkChatUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = playerGui

--═══════════════════════════════════════════════════════════════════════════════
-- TOGGLE BUTTONS (Trái)
--═══════════════════════════════════════════════════════════════════════════════
local function makeToggleButton(text, color, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0, 15, 0.5, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 24
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Active = true
    btn.Parent = ScreenGui

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = btn

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Thickness = 2
    s.Transparency = 0.5
    s.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function()
        TweenService:Create(s, TweenInfo.new(0.15), {Transparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(s, TweenInfo.new(0.15), {Transparency = 0.5}):Play()
    end)
    return btn
end

--═══════════════════════════════════════════════════════════════════════════════
-- CHAT MAIN FRAME - STYLE ROBLOX
--═══════════════════════════════════════════════════════════════════════════════
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 380, 0, 380)
Main.Position = UDim2.new(0, 80, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
Main.BackgroundTransparency = 0.15
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 60)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.3
MainStroke.Parent = Main

-- Header (giống Roblox chat header)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

-- Fix góc dưới header vuông
local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 8)
HeaderFix.Position = UDim2.new(0, 0, 1, -8)
HeaderFix.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0, 200, 1, 0)
HeaderTitle.Position = UDim2.new(0, 12, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "💬 Dark Chat"
HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderTitle.TextSize = 15
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

-- Role badge nhỏ gọn trong header
local HeaderBadge = Instance.new("TextLabel")
HeaderBadge.Size = UDim2.new(0, 80, 0, 18)
HeaderBadge.Position = UDim2.new(1, -130, 0, 9)
HeaderBadge.BackgroundColor3 = MY_STYLE.Color
HeaderBadge.BackgroundTransparency = 0.8
HeaderBadge.Text = MY_STYLE.Icon .. " " .. MY_ROLE
HeaderBadge.TextColor3 = MY_STYLE.Color
HeaderBadge.TextSize = 10
HeaderBadge.Font = Enum.Font.GothamBold
HeaderBadge.Parent = Header

local HeaderBadgeCorner = Instance.new("UICorner")
HeaderBadgeCorner.CornerRadius = UDim.new(0, 9)
HeaderBadgeCorner.Parent = HeaderBadge

-- Close button trong header
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -32, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

--═══════════════════════════════════════════════════════════════════════════════
-- CHAT MESSAGES AREA
--═══════════════════════════════════════════════════════════════════════════════
local ChatScroll = Instance.new("ScrollingFrame")
ChatScroll.Name = "ChatScroll"
ChatScroll.Size = UDim2.new(1, -16, 1, -130)
ChatScroll.Position = UDim2.new(0, 8, 0, 42)
ChatScroll.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ChatScroll.BackgroundTransparency = 0.4
ChatScroll.BorderSizePixel = 0
ChatScroll.ScrollBarThickness = 4
ChatScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
ChatScroll.ScrollBarImageTransparency = 0.4
ChatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ChatScroll.Parent = Main

local ChatCorner = Instance.new("UICorner")
ChatCorner.CornerRadius = UDim.new(0, 6)
ChatCorner.Parent = ChatScroll

local ChatPad = Instance.new("UIPadding")
ChatPad.PaddingTop = UDim.new(0, 6)
ChatPad.PaddingBottom = UDim.new(0, 6)
ChatPad.PaddingLeft = UDim.new(0, 8)
ChatPad.PaddingRight = UDim.new(0, 8)
ChatPad.Parent = ChatScroll

local ChatLayout = Instance.new("UIListLayout")
ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatLayout.Padding = UDim.new(0, 2)
ChatLayout.Parent = ChatScroll

--═══════════════════════════════════════════════════════════════════════════════
-- BAN OVERLAY (hiện khi bị ban)
--═══════════════════════════════════════════════════════════════════════════════
local BanOverlay = Instance.new("Frame")
BanOverlay.Name = "BanOverlay"
BanOverlay.Size = UDim2.new(1, -16, 1, -130)
BanOverlay.Position = UDim2.new(0, 8, 0, 42)
BanOverlay.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
BanOverlay.BackgroundTransparency = 0.1
BanOverlay.BorderSizePixel = 0
BanOverlay.Visible = false
BanOverlay.Parent = Main

local BanCorner = Instance.new("UICorner")
BanCorner.CornerRadius = UDim.new(0, 6)
BanCorner.Parent = BanOverlay

local BanStroke = Instance.new("UIStroke")
BanStroke.Color = Color3.fromRGB(255, 60, 60)
BanStroke.Thickness = 2
BanStroke.Transparency = 0.2
BanStroke.Parent = BanOverlay

local BanIcon = Instance.new("TextLabel")
BanIcon.Size = UDim2.new(1, 0, 0, 70)
BanIcon.Position = UDim2.new(0, 0, 0, 20)
BanIcon.BackgroundTransparency = 1
BanIcon.Text = "🚫"
BanIcon.TextSize = 55
BanIcon.Font = Enum.Font.GothamBold
BanIcon.Parent = BanOverlay

local BanText = Instance.new("TextLabel")
BanText.Size = UDim2.new(1, -20, 0, 30)
BanText.Position = UDim2.new(0, 10, 0, 90)
BanText.BackgroundTransparency = 1
BanText.Text = "Bạn Đã Bị Ban Chat"
BanText.TextColor3 = Color3.fromRGB(255, 60, 60)
BanText.TextSize = 18
BanText.Font = Enum.Font.GothamBold
BanText.Parent = BanOverlay

local BanReason = Instance.new("TextLabel")
BanReason.Size = UDim2.new(1, -20, 0, 60)
BanReason.Position = UDim2.new(0, 10, 0, 125)
BanReason.BackgroundTransparency = 1
BanReason.Text = ""
BanReason.TextColor3 = Color3.fromRGB(255, 180, 180)
BanReason.TextSize = 13
BanReason.Font = Enum.Font.GothamMedium
BanReason.TextWrapped = true
BanReason.Parent = BanOverlay

--═══════════════════════════════════════════════════════════════════════════════
-- INPUT BAR (giống Roblox)
--═══════════════════════════════════════════════════════════════════════════════
local InputBar = Instance.new("Frame")
InputBar.Name = "InputBar"
InputBar.Size = UDim2.new(1, -16, 0, 36)
InputBar.Position = UDim2.new(0, 8, 1, -44)
InputBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
InputBar.BorderSizePixel = 0
InputBar.Parent = Main

local InputBarCorner = Instance.new("UICorner")
InputBarCorner.CornerRadius = UDim.new(0, 6)
InputBarCorner.Parent = InputBar

local InputBarStroke = Instance.new("UIStroke")
InputBarStroke.Color = Color3.fromRGB(70, 70, 70)
InputBarStroke.Thickness = 1
InputBarStroke.Parent = InputBar

local Input = Instance.new("TextBox")
Input.Name = "Input"
Input.Size = UDim2.new(1, -50, 1, -8)
Input.Position = UDim2.new(0, 10, 0, 4)
Input.BackgroundTransparency = 1
Input.Text = ""
Input.PlaceholderText = "Nhập tin nhắn..."
Input.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
Input.TextColor3 = Color3.fromRGB(255, 255, 255)
Input.TextSize = 14
Input.Font = Enum.Font.GothamMedium
Input.TextXAlignment = Enum.TextXAlignment.Left
Input.ClearTextOnFocus = false
Input.Parent = InputBar

local SendBtn = Instance.new("TextButton")
SendBtn.Size = UDim2.new(0, 34, 0, 28)
SendBtn.Position = UDim2.new(1, -40, 0, 4)
SendBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
SendBtn.Text = "➤"
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.TextSize = 16
SendBtn.Font = Enum.Font.GothamBold
SendBtn.AutoButtonColor = false
SendBtn.Parent = InputBar

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 4)
SendCorner.Parent = SendBtn

--═══════════════════════════════════════════════════════════════════════════════
-- HÀM ADD MESSAGE (style Roblox)
--═══════════════════════════════════════════════════════════════════════════════
local function addMessage(senderName, text, isSystem)
    local role = isSystem and "System" or getRole(senderName)
    local style = ROLE_STYLE[role] or ROLE_STYLE.Member

    local msgFrame = Instance.new("Frame")
    msgFrame.Size = UDim2.new(1, 0, 0, 0)
    msgFrame.AutomaticSize = Enum.AutomaticSize.Y
    msgFrame.BackgroundTransparency = 1
    msgFrame.Parent = ChatScroll

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, 0, 0, 0)
    msgLabel.AutomaticSize = Enum.AutomaticSize.Y
    msgLabel.BackgroundTransparency = 1

    if isSystem then
        msgLabel.Text = "🌑 " .. senderName .. ": " .. text
        msgLabel.TextColor3 = Color3.fromRGB(180, 100, 255)
    else
        local tag = style.Tag ~= "" and (style.Tag .. " ") or ""
        msgLabel.Text = style.Icon .. " " .. tag .. senderName .. ": " .. text
        msgLabel.TextColor3 = style.Color
    end

    msgLabel.TextSize = 14
    msgLabel.Font = Enum.Font.GothamMedium
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Parent = msgFrame

    task.wait(0.03)
    ChatScroll.CanvasPosition = Vector2.new(0, ChatScroll.AbsoluteCanvasSize.Y)
end

--═══════════════════════════════════════════════════════════════════════════════
-- CẬP NHẬT TRẠNG THÁI BAN
--═══════════════════════════════════════════════════════════════════════════════
local function updateBanState()
    if isBanned(player.Name) then
        local info = BannedPlayers[string.lower(player.Name)]
        BanOverlay.Visible = true
        ChatScroll.Visible = false
        InputBar.Visible = false
        BanReason.Text = info.reason ~= "" and ("Lý do: " .. info.reason) or "Không có lý do"
    else
        BanOverlay.Visible = false
        ChatScroll.Visible = true
        InputBar.Visible = true
    end
end

--═══════════════════════════════════════════════════════════════════════════════
-- WELCOME MESSAGES
--═══════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    task.wait(0.3)
    addMessage("Dark Chat", "Chào mừng ae VNG & ae chưa xác minh tuổi!", true)
    addMessage("Dark Chat", "By Khanh Beo • VNG Edition", true)
    task.wait(0.3)
    addMessage("Hệ thống", "Role: " .. MY_STYLE.Icon .. " " .. MY_ROLE, true)
    updateBanState()
end)

--═══════════════════════════════════════════════════════════════════════════════
-- SEND MESSAGE
--═══════════════════════════════════════════════════════════════════════════════
local function sendMessage(text)
    if text == "" then return end
    
    if isBanned(player.Name) then
        addMessage("Hệ thống", "🚫 Bạn đã bị ban chat!", true)
        return
    end
    
    local muted, mInfo = isMuted(player.Name)
    if muted then
        local rem = math.ceil((mInfo.until - os.time()) / 60)
        addMessage("Hệ thống", "🔇 Bạn đang bị mute! Còn " .. rem .. " phút.", true)
        return
    end
    
    addMessage(player.Name, text, false)
end

SendBtn.MouseButton1Click:Connect(function()
    if Input.Text ~= "" then
        sendMessage(Input.Text)
        Input.Text = ""
    end
end)

Input.FocusLost:Connect(function(enter)
    if enter and Input.Text ~= "" then
        sendMessage(Input.Text)
        Input.Text = ""
    end
end)

SendBtn.MouseEnter:Connect(function()
    TweenService:Create(SendBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 180, 255)}):Play()
end)
SendBtn.MouseLeave:Connect(function()
    TweenService:Create(SendBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 162, 255)}):Play()
end)

--═══════════════════════════════════════════════════════════════════════════════
-- KÉO THẢ MENU CHAT
--═══════════════════════════════════════════════════════════════════════════════
local draggingMain, dragStartMain, startPosMain = false, nil, nil
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingMain = false
            end
        end)
    end
end)

--═══════════════════════════════════════════════════════════════════════════════
-- ADMIN PANEL
--═══════════════════════════════════════════════════════════════════════════════
local AdminPanel, AdminPanelVisible = nil, false

if I_AM_ADMIN then
    AdminPanel = Instance.new("Frame")
    AdminPanel.Name = "AdminPanel"
    AdminPanel.Size = UDim2.new(0, 420, 0, 500)
    AdminPanel.Position = UDim2.new(0, 80, 0.5, -250)
    AdminPanel.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
    AdminPanel.BackgroundTransparency = 0.1
    AdminPanel.BorderSizePixel = 0
    AdminPanel.Active = true
    AdminPanel.Visible = false
    AdminPanel.Parent = ScreenGui

    local APC = Instance.new("UICorner")
    APC.CornerRadius = UDim.new(0, 8)
    APC.Parent = AdminPanel

    local APS = Instance.new("UIStroke")
    APS.Color = Color3.fromRGB(255, 60, 60)
    APS.Thickness = 1.5
    APS.Transparency = 0.3
    APS.Parent = AdminPanel

    -- Header
    local APHeader = Instance.new("Frame")
    APHeader.Size = UDim2.new(1, 0, 0, 36)
    APHeader.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
    APHeader.BorderSizePixel = 0
    APHeader.Parent = AdminPanel

    local APHC = Instance.new("UICorner")
    APHC.CornerRadius = UDim.new(0, 8)
    APHC.Parent = APHeader

    local APHFix = Instance.new("Frame")
    APHFix.Size = UDim2.new(1, 0, 0, 8)
    APHFix.Position = UDim2.new(0, 0, 1, -8)
    APHFix.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
    APHFix.BorderSizePixel = 0
    APHFix.Parent = APHeader

    local APTitle = Instance.new("TextLabel")
    APTitle.Size = UDim2.new(1, -50, 1, 0)
    APTitle.Position = UDim2.new(0, 12, 0, 0)
    APTitle.BackgroundTransparency = 1
    APTitle.Text = "🛡️ Admin Panel"
    APTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
    APTitle.TextSize = 15
    APTitle.Font = Enum.Font.GothamBold
    APTitle.TextXAlignment = Enum.TextXAlignment.Left
    APTitle.Parent = APHeader

    local APClose = Instance.new("TextButton")
    APClose.Size = UDim2.new(0, 24, 0, 24)
    APClose.Position = UDim2.new(1, -32, 0, 6)
    APClose.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    APClose.Text = "✕"
    APClose.TextColor3 = Color3.fromRGB(255, 255, 255)
    APClose.TextSize = 14
    APClose.Font = Enum.Font.GothamBold
    APClose.AutoButtonColor = false
    APClose.Parent = APHeader

    local APCC = Instance.new("UICorner")
    APCC.CornerRadius = UDim.new(0, 4)
    APCC.Parent = APClose

    -- Tab buttons: Ban | Mute | List
    local TabsFrame = Instance.new("Frame")
    TabsFrame.Size = UDim2.new(1, -20, 0, 34)
    TabsFrame.Position = UDim2.new(0, 10, 0, 44)
    TabsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabsFrame.BorderSizePixel = 0
    TabsFrame.Parent = AdminPanel

    local TFC = Instance.new("UICorner")
    TFC.CornerRadius = UDim.new(0, 6)
    TFC.Parent = TabsFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 2)
    TabLayout.Parent = TabsFrame

    local Tabs = {}
    local TabContents = {}
    local CurrentTab = "Ban"

    local function switchTab(tabName)
        CurrentTab = tabName
        for name, content in pairs(TabContents) do
            content.Visible = (name == tabName)
        end
        for name, btn in pairs(Tabs) do
            btn.BackgroundColor3 = (name == tabName) and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(50, 50, 50)
        end
    end

    local function makeTab(tabName, displayText)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1/3, -2, 1, -4)
        btn.Position = UDim2.new(0, 0, 0, 2)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.Text = displayText
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.AutoButtonColor = false
        btn.Parent = TabsFrame

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = btn

        btn.MouseButton1Click:Connect(function()
            switchTab(tabName)
        end)
        Tabs[tabName] = btn
        return btn
    end

    makeTab("Ban", "🚫 Ban")
    makeTab("Mute", "🔇 Mute")
    makeTab("List", "📋 Danh sách")

    -- Content container
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -20, 1, -90)
    ContentFrame.Position = UDim2.new(0, 10, 0, 84)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = AdminPanel

    --═══ TAB BAN ═══
    local BanTab = Instance.new("Frame")
    BanTab.Size = UDim2.new(1, 0, 1, 0)
    BanTab.BackgroundTransparency = 1
    BanTab.Visible = true
    BanTab.Parent = ContentFrame
    TabContents.Ban = BanTab

    local function makeInput(parent, yPos, label, placeholder, default)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 16)
        lbl.Position = UDim2.new(0, 0, 0, yPos)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
        lbl.TextSize = 11
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, 0, 0, 32)
        box.Position = UDim2.new(0, 0, 0, yPos + 18)
        box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        box.BorderSizePixel = 0
        box.Text = default or ""
        box.PlaceholderText = placeholder
        box.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.TextSize = 12
        box.Font = Enum.Font.GothamMedium
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ClearTextOnFocus = false
        box.Parent = parent

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = box

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 8)
        pad.Parent = box

        return box
    end

    local BanUserInput = makeInput(BanTab, 0, "Tên player cần ban:", "Nhập username...")
    local BanReasonInput = makeInput(BanTab, 62, "Lý do (không bắt buộc):", "Nhập lý do...")

    local BanBtn = Instance.new("TextButton")
    BanBtn.Size = UDim2.new(1, 0, 0, 40)
    BanBtn.Position = UDim2.new(0, 0, 0, 140)
    BanBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    BanBtn.Text = "🚫 BAN CHAT"
    BanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BanBtn.TextSize = 14
    BanBtn.Font = Enum.Font.GothamBold
    BanBtn.AutoButtonColor = false
    BanBtn.Parent = BanTab

    local BBC = Instance.new("UICorner")
    BBC.CornerRadius = UDim.new(0, 6)
    BBC.Parent = BanBtn

    local BanResult = Instance.new("TextLabel")
    BanResult.Size = UDim2.new(1, 0, 0, 20)
    BanResult.Position = UDim2.new(0, 0, 0, 188)
    BanResult.BackgroundTransparency = 1
    BanResult.Text = ""
    BanResult.TextColor3 = Color3.fromRGB(100, 255, 150)
    BanResult.TextSize = 12
    BanResult.Font = Enum.Font.GothamMedium
    BanResult.Parent = BanTab

    BanBtn.MouseButton1Click:Connect(function()
        local target = BanUserInput.Text
        if target == "" then
            BanResult.TextColor3 = Color3.fromRGB(255, 100, 100)
            BanResult.Text = "⚠ Vui lòng nhập tên player"
            return
        end
        if string.lower(target) == string.lower(player.Name) then
            BanResult.TextColor3 = Color3.fromRGB(255, 100, 100)
            BanResult.Text = "⚠ Không thể tự ban mình!"
            return
        end
        BannedPlayers[string.lower(target)] = {
            reason = BanReasonInput.Text,
            by = player.Name,
            time = os.time()
        }
        saveDB()
        BanResult.TextColor3 = Color3.fromRGB(100, 255, 150)
        BanResult.Text = "✔ Đã ban " .. target
        BanUserInput.Text = ""
        BanReasonInput.Text = ""
        -- Nếu ban chính mình → cập nhật
        updateBanState()
    end)

    --═══ TAB MUTE ═══
    local MuteTab = Instance.new("Frame")
    MuteTab.Size = UDim2.new(1, 0, 1, 0)
    MuteTab.BackgroundTransparency = 1
    MuteTab.Visible = false
    MuteTab.Parent = ContentFrame
    TabContents.Mute = MuteTab

    local MuteUserInput = makeInput(MuteTab, 0, "Tên player cần mute:", "Nhập username...")
    local MuteReasonInput = makeInput(MuteTab, 62, "Lý do (không bắt buộc):", "Nhập lý do...")
    local MuteTimeInput = makeInput(MuteTab, 124, "Thời gian mute (phút):", "VD: 60 = 1 giờ", "60")

    local MuteBtn = Instance.new("TextButton")
    MuteBtn.Size = UDim2.new(1, 0, 0, 40)
    MuteBtn.Position = UDim2.new(0, 0, 0, 202)
    MuteBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    MuteBtn.Text = "🔇 MUTE CHAT"
    MuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MuteBtn.TextSize = 14
    MuteBtn.Font = Enum.Font.GothamBold
    MuteBtn.AutoButtonColor = false
    MuteBtn.Parent = MuteTab

    local MBC = Instance.new("UICorner")
    MBC.CornerRadius = UDim.new(0, 6)
    MBC.Parent = MuteBtn

    local MuteResult = Instance.new("TextLabel")
    MuteResult.Size = UDim2.new(1, 0, 0, 20)
    MuteResult.Position = UDim2.new(0, 0, 0, 250)
    MuteResult.BackgroundTransparency = 1
    MuteResult.Text = ""
    MuteResult.TextColor3 = Color3.fromRGB(100, 255, 150)
    MuteResult.TextSize = 12
    MuteResult.Font = Enum.Font.GothamMedium
    MuteResult.Parent = MuteTab

    MuteBtn.MouseButton1Click:Connect(function()
        local target = MuteUserInput.Text
        local mins = tonumber(MuteTimeInput.Text)
        if target == "" then
            MuteResult.TextColor3 = Color3.fromRGB(255, 100, 100)
            MuteResult.Text = "⚠ Vui lòng nhập tên player"
            return
        end
        if not mins or mins <= 0 then
            MuteResult.TextColor3 = Color3.fromRGB(255, 100, 100)
            MuteResult.Text = "⚠ Thời gian không hợp lệ"
            return
        end
        if string.lower(target) == string.lower(player.Name) then
            MuteResult.TextColor3 = Color3.fromRGB(255, 100, 100)
            MuteResult.Text = "⚠ Không thể tự mute mình!"
            return
        end
        MutedPlayers[string.lower(target)] = {
            until_time = os.time() + (mins * 60),
            until = os.time() + (mins * 60),
            reason = MuteReasonInput.Text,
            by = player.Name
        }
        saveDB()
        MuteResult.TextColor3 = Color3.fromRGB(100, 255, 150)
        MuteResult.Text = "✔ Đã mute " .. target .. " trong " .. mins .. " phút"
        MuteUserInput.Text = ""
        MuteReasonInput.Text = ""
    end)

    --═══ TAB LIST (Danh sách player) ═══
    local ListTab = Instance.new("Frame")
    ListTab.Size = UDim2.new(1, 0, 1, 0)
    ListTab.BackgroundTransparency = 1
    ListTab.Visible = false
    ListTab.Parent = ContentFrame
    TabContents.List = ListTab

    local ListHeader = Instance.new("TextLabel")
    ListHeader.Size = UDim2.new(1, 0, 0, 20)
    ListHeader.BackgroundTransparency = 1
    ListHeader.Text = "📋 Người trong game (có thể ban/mute):"
    ListHeader.TextColor3 = Color3.fromRGB(200, 200, 220)
    ListHeader.TextSize = 11
    ListHeader.Font = Enum.Font.GothamBold
    ListHeader.TextXAlignment = Enum.TextXAlignment.Left
    ListHeader.Parent = ListTab

    local ListScroll = Instance.new("ScrollingFrame")
    ListScroll.Size = UDim2.new(1, 0, 1, -30)
    ListScroll.Position = UDim2.new(0, 0, 0, 26)
    ListScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    ListScroll.BorderSizePixel = 0
    ListScroll.ScrollBarThickness = 4
    ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ListScroll.Parent = ListTab

    local LSC = Instance.new("UICorner")
    LSC.CornerRadius = UDim.new(0, 6)
    LSC.Parent = ListScroll

    local LSPad = Instance.new("UIPadding")
    LSPad.PaddingTop = UDim.new(0, 4)
    LSPad.PaddingBottom = UDim.new(0, 4)
    LSPad.PaddingLeft = UDim.new(0, 4)
    LSPad.PaddingRight = UDim.new(0, 4)
    LSPad.Parent = ListScroll

    local LSLayout = Instance.new("UIListLayout")
    LSLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LSLayout.Padding = UDim.new(0, 3)
    LSLayout.Parent = ListScroll

    local function refreshList()
        for _, child in ipairs(ListScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        local users = getActiveScriptUsers()
        for i, u in ipairs(users) do
            local userFrame = Instance.new("Frame")
            userFrame.Size = UDim2.new(1, -8, 0, 40)
            userFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            userFrame.BorderSizePixel = 0
            userFrame.Parent = ListScroll

            local UFC = Instance.new("UICorner")
            UFC.CornerRadius = UDim.new(0, 4)
            UFC.Parent = userFrame

            local style = ROLE_STYLE[u.Role] or ROLE_STYLE.Member

            local userIcon = Instance.new("TextLabel")
            userIcon.Size = UDim2.new(0, 30, 1, 0)
            userIcon.Position = UDim2.new(0, 4, 0, 0)
            userIcon.BackgroundTransparency = 1
            userIcon.Text = style.Icon
            userIcon.TextSize = 18
            userIcon.Font = Enum.Font.GothamBold
            userIcon.Parent = userFrame

            local userName = Instance.new("TextLabel")
            userName.Size = UDim2.new(0.5, -40, 1, 0)
            userName.Position = UDim2.new(0, 36, 0, 0)
            userName.BackgroundTransparency = 1
            userName.Text = u.DisplayName .. (u.IsSelf and " (Bạn)" or "")
            userName.TextColor3 = style.Color
            userName.TextSize = 12
            userName.Font = Enum.Font.GothamBold
            userName.TextXAlignment = Enum.TextXAlignment.Left
            userName.Parent = userFrame

            -- Trạng thái ban/mute
            local status = ""
            local statusColor = Color3.fromRGB(150, 150, 150)
            if isBanned(u.Name) then
                status = "🚫 BAN"
                statusColor = Color3.fromRGB(255, 60, 60)
            else
                local muted = isMuted(u.Name)
                if muted then
                    status = "🔇 MUTE"
                    statusColor = Color3.fromRGB(255, 140, 0)
                end
            end

            if status ~= "" then
                local statusLbl = Instance.new("TextLabel")
                statusLbl.Size = UDim2.new(0, 55, 1, 0)
                statusLbl.Position = UDim2.new(0.5, -10, 0, 0)
                statusLbl.BackgroundTransparency = 1
                statusLbl.Text = status
                statusLbl.TextColor3 = statusColor
                statusLbl.TextSize = 10
                statusLbl.Font = Enum.Font.GothamBold
                statusLbl.Parent = userFrame
            end

            -- Nút Unban (nếu đang ban)
            if isBanned(u.Name) then
                local unbanBtn = Instance.new("TextButton")
                unbanBtn.Size = UDim2.new(0, 55, 0, 26)
                unbanBtn.Position = UDim2.new(1, -60, 0, 7)
                unbanBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
                unbanBtn.Text = "UNBAN"
                unbanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                unbanBtn.TextSize = 10
                unbanBtn.Font = Enum.Font.GothamBold
                unbanBtn.AutoButtonColor = false
                unbanBtn.Parent = userFrame

                local UBC = Instance.new("UICorner")
                UBC.CornerRadius = UDim.new(0, 4)
                UBC.Parent = unbanBtn

                unbanBtn.MouseButton1Click:Connect(function()
                    BannedPlayers[string.lower(u.Name)] = nil
                    saveDB()
                    updateBanState()
                    refreshList()
                end)
            end

            -- Nút Unmute (nếu đang mute)
            local muted = isMuted(u.Name)
            if muted and not isBanned(u.Name) then
                local unmuteBtn = Instance.new("TextButton")
                unmuteBtn.Size = UDim2.new(0, 55, 0, 26)
                unmuteBtn.Position = UDim2.new(1, -60, 0, 7)
                unmuteBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
                unmuteBtn.Text = "UNMUTE"
                unmuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                unmuteBtn.TextSize = 9
                unmuteBtn.Font = Enum.Font.GothamBold
                unmuteBtn.AutoButtonColor = false
                unmuteBtn.Parent = userFrame

                local UMC = Instance.new("UICorner")
                UMC.CornerRadius = UDim.new(0, 4)
                UMC.Parent = unmuteBtn

                unmuteBtn.MouseButton1Click:Connect(function()
                    MutedPlayers[string.lower(u.Name)] = nil
                    saveDB()
                    refreshList()
                end)
            end
        end
    end

    -- Refresh list khi mở tab hoặc khi player thay đổi
    Players.PlayerAdded:Connect(function() if CurrentTab == "List" then refreshList() end end)
    Players.PlayerRemoving:Connect(function() if CurrentTab == "List" then refreshList() end end)

    local originalSwitch = switchTab
    switchTab = function(tabName)
        originalSwitch(tabName)
        if tabName == "List" then
            refreshList()
        end
    end

    -- Override tab click
    for name, btn in pairs(Tabs) do
        local conns = btn.MouseButton1Click:GetConnections()
        for _, c in ipairs(conns) do c:Disconnect() end
        btn.MouseButton1Click:Connect(function()
            switchTab(name)
        end)
    end

    -- Đóng panel
    APClose.MouseButton1Click:Connect(function()
        AdminPanel.Visible = false
        AdminPanelVisible = false
    end)

    -- Kéo thả panel
    local dragAP, dragStartAP, startPosAP = false, nil, nil
    APHeader.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragAP = true
            dragStartAP = input.Position
            startPosAP = AdminPanel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragAP = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragAP and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartAP
            AdminPanel.Position = UDim2.new(
                startPosAP.X.Scale,
                startPosAP.X.Offset + delta.X,
                startPosAP.Y.Scale,
                startPosAP.Y.Offset + delta.Y
            )
        end
    end)
end

--═══════════════════════════════════════════════════════════════════════════════
-- TOGGLE BUTTONS
--═══════════════════════════════════════════════════════════════════════════════
local chatOpen = false
local chatAnim = false

local function openChat()
    if chatOpen or chatAnim then return end
    chatAnim = true
    chatOpen = true
    Main.Visible = true
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.BackgroundTransparency = 1
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 380, 0, 380),
        BackgroundTransparency = 0.15
    }):Play()
    task.wait(0.3)
    chatAnim = false
end

local function closeChat()
    if not chatOpen or chatAnim then return end
    chatAnim = true
    chatOpen = false
    TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.2)
    Main.Visible = false
    chatAnim = false
end

local ChatToggleBtn = makeToggleButton("💬", Color3.fromRGB(0, 162, 255), -60, function()
    if chatOpen then closeChat() else openChat() end
end)

-- Nút Admin Panel (chỉ hiện nếu admin)
local AdminToggleBtn
if I_AM_ADMIN and AdminPanel then
    AdminToggleBtn = makeToggleButton("🛡️", Color3.fromRGB(255, 60, 60), 5, function()
        AdminPanel.Visible = not AdminPanel.Visible
        AdminPanelVisible = AdminPanel.Visible
    end)
end

--═══════════════════════════════════════════════════════════════════════════════
-- KÉO THẢ TOGGLE BUTTONS
--═══════════════════════════════════════════════════════════════════════════════
local function makeDraggable(btn)
    local drag, dragStart, startPos = false, nil, nil
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dragStart = input.Position
            startPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    drag = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(ChatToggleBtn)
if AdminToggleBtn then makeDraggable(AdminToggleBtn) end

--═══════════════════════════════════════════════════════════════════════════════
-- GLOBAL DRAG HANDLER
--═══════════════════════════════════════════════════════════════════════════════
UserInputService.InputChanged:Connect(function(input)
    if draggingMain and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartMain
        Main.Position = UDim2.new(
            startPosMain.X.Scale,
            startPosMain.X.Offset + delta.X,
            startPosMain.Y.Scale,
            startPosMain.Y.Offset + delta.Y
        )
    end
end)

--═══════════════════════════════════════════════════════════════════════════════
-- CLOSE BUTTON CHAT
--═══════════════════════════════════════════════════════════════════════════════
CloseBtn.MouseButton1Click:Connect(function()
    closeChat()
end)

--═══════════════════════════════════════════════════════════════════════════════
-- PHÍM TẮT: Right Ctrl = mở/đóng chat
--═══════════════════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        if chatOpen then closeChat() else openChat() end
    end
end)

--═══════════════════════════════════════════════════════════════════════════════
-- LOG
--═══════════════════════════════════════════════════════════════════════════════
print("═══════════════════════════════════════")
print("🌑 DARK CHAT V6 - OFFICIAL RELEASE")
print("📌 By Khanh Beo")
print("👤 User: " .. player.Name)
print("👑 Role: " .. MY_STYLE.Icon .. " " .. MY_ROLE)
print("🛡️ Admin Panel: " .. (I_AM_ADMIN and "ĐÃ BẬT" or "ẨN (không có quyền)"))
print("⌨️  Right Ctrl để mở/đóng chat")
print("═══════════════════════════════════════")